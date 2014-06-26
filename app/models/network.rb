class Network < ActiveRecord::Base
  attr_accessible :description, :owner, :owner_id, :title

  belongs_to :owner, :class_name => 'Person'

  has_many :memberships, :class_name => 'NetworkMembership'
  has_many :members, :through => :memberships, :source => :person, :conditions => ['network_memberships.accepted_at IS NOT NULL']
  has_many :administrators, :through => :memberships, :source => :person, :conditions => ['network_memberships.accepted_at IS NOT NULL AND network_memberships.administrator']

  acts_as_yellow_pages

  scope :default_order, order('title')

  def self.user_creatable?
    true
  end

  def related_people
    members + [owner]
  end

  def member?(person)
    !person.nil? && (admin?(person) || members.include?(person.is_a?(Person) ? person : person.person))
  end

  def admin?(person)
    !person.nil? && (owner?(person) || administrators.include?(person.is_a?(Person) ? person : person.person))
  end

  def owner?(person)
    !person.nil? && (owner == (person.is_a?(Person) ? person : person.person))
  end

end

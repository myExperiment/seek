class Network < ActiveRecord::Base
  attr_accessible :description, :owner, :owner_id, :title

  belongs_to :owner, :class_name => 'Person'

  has_many :memberships, :class_name => 'NetworkMembership'
  has_many :members, :through => :memberships, :source => :person, :conditions => ['network_memberships.accepted_at IS NOT NULL']
  has_many :administrators, :through => :memberships, :source => :person, :conditions => ['network_memberships.accepted_at IS NOT NULL AND network_memberships.administrator']
  has_many :invited_people, :through => :memberships, :source => :person, :conditions => ['network_memberships.accepted_at IS NULL']

  acts_as_yellow_pages

  scope :default_order, order('title')

  def self.user_creatable?
    true
  end

end

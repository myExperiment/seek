class NetworkMembership < ActiveRecord::Base
  attr_accessible :administrator, :inviter_id, :message, :network_id, :person_id, :accept

  belongs_to :person
  belongs_to :network
  belongs_to :inviter, :class_name => 'Person'

  scope :accepted, -> { where('accepted_at IS NOT NULL') }
  scope :invited, -> { where('accepted_at IS NULL') }
  scope :administrators, -> { where(:administrator => true) }

  validates :person_id, :presence => true, :uniqueness => { :scope => :network_id, :message => 'Invitation already sent.' }
  validates :network_id, :presence => true
  validate :not_owner

  def accepted?
    !self.accepted_at.nil?
  end

  def accept=(yes)
    if yes
      accept
    else
      false
    end
  end

  def accept
    self.accepted_at = Time.now
    accepted?
  end

  private

  def not_owner
    if network.owner?(self.person)
      self.errors[:base] << "#{self.person.name} is the #{t('network')} owner"
      false
    else
      true
    end
  end

end

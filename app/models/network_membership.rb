class NetworkMembership < ActiveRecord::Base
  attr_accessible :accepted_at, :administrator, :invited_by, :message, :network_id, :person_id

  belongs_to :person
  belongs_to :network
  belongs_to :invited_by, :class_name => 'Person'

  def accepted?
    !self.accepted_at.nil?
  end

  def accept
    self.accepted_at = Time.now
    accepted?
  end

end

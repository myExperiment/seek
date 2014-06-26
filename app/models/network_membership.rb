class NetworkMembership < ActiveRecord::Base
  attr_accessible :administrator, :inviter_id, :message, :network_id, :person_id, :accept

  belongs_to :person
  belongs_to :network
  belongs_to :inviter, :class_name => 'Person'

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

end

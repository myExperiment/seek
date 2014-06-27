class Friendship < ActiveRecord::Base
  belongs_to :person

  validates :person, :friend_id, :status, presence:true
  validates :status, numericality: {greater_than_or_equal_to: 0, less_than: 3}

  validate :friend_exists
  validate :can_request_friendship

  FRIENDSHIP_STATUSES = %w{None Pending Accepted}

  def friend
    return Person.find_by_id(self.friend_id)
  end

  def accept_request
    self.update_attribute(:status, 2)
  end

  def self.friendship_status(person_id, friend_id)
    Friendship.where(:person_id => person_id, :friend_id => friend_id).first.try(:status) ||
        Friendship.where(:person_id => friend_id, :friend_id => person_id).first.try(:status) || 0
  end

  private

  def friend_exists
    Person.find_by_id(friend_id).nil?
  end

  def can_request_friendship
    status = Friendship.friendship_status(person.id, friend_id)
    return true if status == 0
  end
end


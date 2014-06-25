class Friendship < ActiveRecord::Base
  belongs_to :person

  validates :person, :friend, :status, presence:true
  validates :status, numericality: {greater_than_or_equal_to: 0, less_than: 3}

  validate :friend_exists



  private

  def friend_exists
    Person.find_by_id(friend).nil?
  end

end


class RenameFriendColumnToFriendIdColumn < ActiveRecord::Migration
  def up
    rename_column :friendships, :friend, :friend_id
  end

  def down
    rename_column :friendships, :friend_id, :friend
  end
end

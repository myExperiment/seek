class CreateFriendships < ActiveRecord::Migration
  def change
    create_table :friendships do |t|
      t.references :person
      t.integer :friend
      t.integer :status

      t.timestamps
    end
    add_index :friendships, :person_id
  end
end

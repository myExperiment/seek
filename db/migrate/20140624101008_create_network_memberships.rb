class CreateNetworkMemberships < ActiveRecord::Migration
  def change
    create_table :network_memberships do |t|
      t.belongs_to :person
      t.belongs_to :network
      t.belongs_to :inviter
      t.boolean :administrator
      t.string :message
      t.datetime :accepted_at

      t.timestamps
    end
  end
end

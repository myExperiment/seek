class AddUuidToNetworks < ActiveRecord::Migration
  def change
    add_column :networks, :uuid, :string
  end
end

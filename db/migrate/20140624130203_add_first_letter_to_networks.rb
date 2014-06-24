class AddFirstLetterToNetworks < ActiveRecord::Migration
  def change
    add_column :networks, :first_letter, :string, :limit => 1
  end
end

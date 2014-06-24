class CreateNetworks < ActiveRecord::Migration
  def change
    create_table :networks do |t|
      t.belongs_to :owner
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end

class CreateSubnetworks < ActiveRecord::Migration[6.0]
  def change
    create_table :subnetworks do |t|
      t.string :name, null: false
      t.references :network_category, null: false, foreign_key: true
      t.integer :vlan

      t.timestamps
    end

    add_index :subnetworks, :name, unique: true
  end
end

class CreateSubnetworks < ActiveRecord::Migration[6.0]
  def change
    create_table :subnetworks do |t|
      t.string :name, null: false
      t.references :network_category, null: false, foreign_key: true
      t.integer :vlan, null: false

      t.timestamps
    end

    add_index :subnetworks, :name, unique: true
    add_index :subnetworks, :vlan, unique: true
  end
end

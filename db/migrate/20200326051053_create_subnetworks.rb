class CreateSubnetworks < ActiveRecord::Migration[6.0]
  def change
    create_table :subnetworks do |t|
      t.string :name
      t.references :network_type, null: false, foreign_key: true
      t.integer :vlan

      t.timestamps
    end
  end
end

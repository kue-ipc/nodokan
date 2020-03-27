class CreateNetworkInterfaces < ActiveRecord::Migration[6.0]
  def change
    create_table :network_interfaces do |t|
      t.references :node, null: false, foreign_key: true
      t.string :name
      t.integer :interface_type
      t.string :mac_address
      t.string :duid

      t.timestamps
    end
    add_index :network_interfaces, :mac_address
    add_index :network_interfaces, :duid
  end
end

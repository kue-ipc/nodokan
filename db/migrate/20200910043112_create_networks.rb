class CreateNetworks < ActiveRecord::Migration[6.0]
  def change
    create_table :networks do |t|
      t.string :name, null: false
      t.integer :vlan
      t.boolean :dhcp, null: false, default: false
      t.boolean :auth, null: false, default: false
      t.boolean :closed, null: false, default: false
      t.binary :ip_address, limit: 4
      t.integer :ip_prefix
      t.binary :ip_gateway, limit: 4
      t.binary :ip6_address, limit: 16
      t.integer :ip6_prefix
      t.binary :ip6_gateway, limit: 16

      t.timestamps
    end
    add_index :networks, :name, unique: true
  end
end

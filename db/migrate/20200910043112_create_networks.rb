class CreateNetworks < ActiveRecord::Migration[6.0]
  def change
    create_table :networks do |t|
      t.string :name, null: false, index: {unique: true}
      t.integer :vlan
      t.boolean :auth, null: false, default: false
      t.binary :ipv4_network_data, limit: 4
      t.integer :ipv4_prefixlen
      t.binary :ipv4_gateway_data, limit: 4
      t.binary :ipv6_network_data, limit: 16
      t.integer :ipv6_prefixlen
      t.binary :ipv6_gateway_data, limit: 16

      t.text :note

      t.timestamps
    end
  end
end

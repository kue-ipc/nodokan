class CreateNetworks < ActiveRecord::Migration[6.0]
  def change
    create_table :networks do |t|
      t.string :name, null: false, index: {unique: true}
      t.integer :vlan
      t.boolean :auth, null: false, default: false
      t.binary :ip_network_data, limit: 4
      t.integer :ip_prefixlen
      t.binary :ip_gateway_data, limit: 4
      t.binary :ip6_network_data, limit: 16
      t.integer :ip6_prefixlen
      t.binary :ip6_gateway_data, limit: 16

      t.text :note

      t.timestamps
    end
  end
end

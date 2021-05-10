class CreateNetworks < ActiveRecord::Migration[6.0]
  def change
    create_table :networks do |t|
      t.string  :name, null: false, index: {unique: true}
      t.integer :vlan,              index: {unique: true}

      t.boolean :auth, null: false, default: false

      t.binary  :ipv4_network_data,  limit: 4,  index: {unique: true}
      t.integer :ipv4_prefix_length, limit: 1,  null: false, default: 0
      t.binary  :ipv4_gateway_data,  limit: 4
      t.binary  :ipv6_network_data,  limit: 16, index: {unique: true}
      t.integer :ipv6_prefix_length, limit: 1,  null: false, default: 0
      t.binary  :ipv6_gateway_data,  limit: 16

      t.text :note

      t.integer :nics_count, null: false, default: 0
      t.integer :assignments_count, null: false, default: 0

      t.timestamps
    end
  end
end

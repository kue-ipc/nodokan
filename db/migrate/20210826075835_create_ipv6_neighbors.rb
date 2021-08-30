class CreateIpv6Neighbors < ActiveRecord::Migration[6.1]
  def change
    create_table :ipv6_neighbors do |t|
      t.binary :ipv6_data,        null: false, limit: 16, index: true
      t.binary :mac_address_data, null: false, limit:  6, index: true
      t.datetime :discovered_at,  null: false

      t.timestamps
    end

    add_index :ipv6_neighbors, [:ipv6_data, :mac_address_data], unique: true
  end
end

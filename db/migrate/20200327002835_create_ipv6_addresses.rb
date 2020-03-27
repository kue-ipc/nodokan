class CreateIpv6Addresses < ActiveRecord::Migration[6.0]
  def change
    create_table :ipv6_addresses do |t|
      t.references :network_connection, null: false, foreign_key: true
      t.boolean :dhcp
      t.boolean :reserved
      t.string :ip_address
      t.string :mac_address
      t.string :duid

      t.timestamps
    end
    add_index :ipv6_addresses, :ip_address
    add_index :ipv6_addresses, :mac_address
  end
end

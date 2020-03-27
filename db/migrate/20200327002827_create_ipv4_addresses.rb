class CreateIpv4Addresses < ActiveRecord::Migration[6.0]
  def change
    create_table :ipv4_addresses do |t|
      t.references :network_connection, null: false, foreign_key: true
      t.boolean :dhcp
      t.boolean :reserved
      t.string :ip_address
      t.string :mac_address

      t.timestamps
    end
    add_index :ipv4_addresses, :ip_address
    add_index :ipv4_addresses, :mac_address
  end
end

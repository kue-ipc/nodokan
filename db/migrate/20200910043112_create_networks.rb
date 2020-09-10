class CreateNetworks < ActiveRecord::Migration[6.0]
  def change
    create_table :networks do |t|
      t.string :name
      t.integer :vlan
      t.boolean :dhcp
      t.boolean :auth
      t.boolean :closed
      t.binary :ip_address
      t.integer :ip_prefix
      t.binary :ip_gateway
      t.binary :ip6_address
      t.integer :ip6_prefix
      t.binary :ip6_gateway

      t.timestamps
    end

    add_index :networks, :name, unique: true

  end
end

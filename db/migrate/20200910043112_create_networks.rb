class CreateNetworks < ActiveRecord::Migration[6.0]
  def change
    create_table :networks do |t|
      t.string :name, null: false, index: {unique: true}
      t.integer :vlan
      t.boolean :dhcp, null: false, default: false
      t.boolean :auth, null: false, default: false
      t.boolean :closed, null: false, default: false
      t.string :ip_address, limit: 16
      t.string :ip_mask, limit: 16
      t.string :ip_gateway, limit: 16
      t.string :ip6_address, limit: 40
      t.integer :ip6_prefix
      t.string :ip6_gateway, limit: 40

      t.text :note

      t.timestamps
    end
  end
end

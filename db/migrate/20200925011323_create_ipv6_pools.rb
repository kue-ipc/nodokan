class CreateIpv6Pools < ActiveRecord::Migration[6.0]
  def change
    create_table :ipv6_pools do |t|
      t.references :network, null: false, foreign_key: true
      t.integer :ipv6_config, null: false
      t.binary :ipv6_first_data, null: false, limit: 16
      t.binary :ipv6_last_data, null: false, limit: 16

      t.timestamps
    end
  end
end

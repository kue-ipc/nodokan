class CreateIpv6Pools < ActiveRecord::Migration[6.0]
  def change
    create_table :ipv6_pools do |t|
      t.references :network, null: false, foreign_key: true
      t.integer :ipv6_config,    limit: 1,  null: false
      t.binary :ipv6_first_data, limit: 16, null: false
      t.binary :ipv6_last_data,  limit: 16, null: false

      t.timestamps
    end
  end
end

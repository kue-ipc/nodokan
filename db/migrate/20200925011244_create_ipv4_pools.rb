class CreateIpv4Pools < ActiveRecord::Migration[6.0]
  def change
    create_table :ipv4_pools do |t|
      t.references :network, null: false, foreign_key: true
      t.integer :ipv4_config,    limit: 1, null: false
      t.binary :ipv4_first_data, limit: 4, null: false
      t.binary :ipv4_last_data,  limit: 4, null: false

      t.timestamps
    end
  end
end

class CreateIpv4Pools < ActiveRecord::Migration[6.0]
  def change
    create_table :ipv4_pools do |t|
      t.references :network, null: false, foreign_key: true
      t.integer :ipv4_config, null: false
      t.binary :ipv4_first_data, null: false, limit: 4
      t.binary :ipv4_last_data, null: false, limit: 4

      t.timestamps
    end
  end
end

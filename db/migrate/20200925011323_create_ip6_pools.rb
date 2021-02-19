class CreateIp6Pools < ActiveRecord::Migration[6.0]
  def change
    create_table :ip6_pools do |t|
      t.references :network, null: false, foreign_key: true
      t.integer :ip6_config, null: false
      t.binary :ip6_first_data, null: false, limit: 16
      t.binary :ip6_last_data, null: false, limit: 16

      t.timestamps
    end
  end
end

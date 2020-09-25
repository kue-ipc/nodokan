class CreateIp6Pools < ActiveRecord::Migration[6.0]
  def change
    create_table :ip6_pools do |t|
      t.references :network, null: false, foreign_key: true
      t.integer :ip6_config, null: false
      t.binary :first6_address, null: false, limit: 16
      t.binary :last6_address, null: false, limit: 16

      t.timestamps
    end
  end
end

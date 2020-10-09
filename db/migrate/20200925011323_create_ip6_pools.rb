class CreateIp6Pools < ActiveRecord::Migration[6.0]
  def change
    create_table :ip6_pools do |t|
      t.references :network, null: false, foreign_key: true
      t.integer :ip6_config, null: false
      t.string :first6_address, null: false, limit: 40
      t.string :last6_address, null: false, limit: 40

      t.timestamps
    end
  end
end

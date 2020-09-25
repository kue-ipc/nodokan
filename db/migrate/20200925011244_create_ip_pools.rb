class CreateIpPools < ActiveRecord::Migration[6.0]
  def change
    create_table :ip_pools do |t|
      t.references :network, null: false, foreign_key: true
      t.integer :ip_config, null: false
      t.binary :first_address, null: false, limit: 4
      t.binary :last_address, null: false, limit: 4

      t.timestamps
    end
  end
end

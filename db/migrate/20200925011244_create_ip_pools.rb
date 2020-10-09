class CreateIpPools < ActiveRecord::Migration[6.0]
  def change
    create_table :ip_pools do |t|
      t.references :network, null: false, foreign_key: true
      t.integer :ip_config, null: false
      t.string :first_address, null: false, limit: 16
      t.string :last_address, null: false, limit: 16

      t.timestamps
    end
  end
end

class CreateIpPools < ActiveRecord::Migration[6.0]
  def change
    create_table :ip_pools do |t|
      t.references :subnetwork, null: false, foreign_key: true
      t.integer :family, null: false
      t.string :first, null: false
      t.string :last, null: false
      t.integer :config, null: false

      t.integer :ip_address_count, null: false, default: 0

      t.timestamps
    end
  end
end

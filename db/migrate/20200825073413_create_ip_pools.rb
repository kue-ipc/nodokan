class CreateIpPools < ActiveRecord::Migration[6.0]
  def change
    create_table :ip_pools do |t|
      t.references :subnetwork, null: false, foreign_key: true
      t.integer :ip_version, null: false
      t.string :begin_address, null: false
      t.string :end_address, null: false
      t.integer :config, null: false

      t.timestamps
    end
  end
end

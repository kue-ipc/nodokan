class CreateIpNetworks < ActiveRecord::Migration[6.0]
  def change
    create_table :ip_networks do |t|
      t.references :subnetwork, null: false, foreign_key: true
      t.integer :ip_version
      t.string :address
      t.integer :mask
      t.string :gateway

      t.timestamps
    end
    add_index :ip_networks, :address
  end
end

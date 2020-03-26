class CreateIpv4Networks < ActiveRecord::Migration[6.0]
  def change
    create_table :ipv4_networks do |t|
      t.references :subnetwork, null: false, foreign_key: true
      t.string :address, null: false
      t.string :subnet_mask
      t.string :default_gateway

      t.timestamps
    end

    add_index :ipv4_networks, :address
  end
end

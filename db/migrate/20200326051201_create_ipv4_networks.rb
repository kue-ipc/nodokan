class CreateIpv4Networks < ActiveRecord::Migration[6.0]
  def change
    create_table :ipv4_networks do |t|
      t.references :subnetwork, null: false, foreign_key: true
      t.string :address
      t.string :subnet_mask
      t.string :default_gateway

      t.timestamps
    end
  end
end

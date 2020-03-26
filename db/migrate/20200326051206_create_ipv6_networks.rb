class CreateIpv6Networks < ActiveRecord::Migration[6.0]
  def change
    create_table :ipv6_networks do |t|
      t.references :subnetwork, null: false, foreign_key: true
      t.string :address
      t.integer :prefix_length
      t.string :default_gateway

      t.timestamps
    end
  end
end

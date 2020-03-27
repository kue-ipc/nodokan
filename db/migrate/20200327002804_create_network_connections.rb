class CreateNetworkConnections < ActiveRecord::Migration[6.0]
  def change
    create_table :network_connections do |t|
      t.references :network_interface, null: false, foreign_key: true
      t.references :subnetwork, null: false, foreign_key: true
      t.boolean :mac_address_randomization

      t.timestamps
    end
  end
end

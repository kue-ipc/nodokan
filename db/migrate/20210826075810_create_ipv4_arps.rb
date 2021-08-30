class CreateIpv4Arps < ActiveRecord::Migration[6.1]
  def change
    create_table :ipv4_arps do |t|
      t.binary :ipv4_data,        null: false, limit: 4, index: true 
      t.binary :mac_address_data, null: false, limit: 6, index: true
      t.datetime :resolved_at,  null: false

      t.timestamps
    end

    add_index :ipv4_arps, [:ipv4_data, :mac_address_data], unique: true
  end
end

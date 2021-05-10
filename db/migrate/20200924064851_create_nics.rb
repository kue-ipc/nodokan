class CreateNics < ActiveRecord::Migration[6.0]
  def change
    create_table :nics do |t|
      t.references :node, null: false, foreign_key: true
      t.references :network, foreign_key: true

      t.string  :name
      t.integer :interface_type, null: false

      t.boolean :auth, null: false, default: false
      t.boolean :locked, null: false, default: false

      t.binary  :mac_address_data, limit: 6,   index: {unique: true}
      t.binary  :duid_data,        limit: 130, index: {unique: true}

      t.integer :ipv4_config, null: false, default: -1
      t.binary  :ipv4_data,   limit: 4,    index: {unique: true}
      t.integer :ipv6_config, null: false, default: -1
      t.binary  :ipv6_data,   limit: 16,   index: {unique: true}

      t.timestamps
    end
  end
end

class CreateNics < ActiveRecord::Migration[6.0]
  def change
    create_table :nics do |t|
      t.references :node, null: false, foreign_key: true
      t.references :network, null: false, foreign_key: true
      t.string :name
      t.binary :mac_address, limit: 6
      t.binary :duid
      t.integer :ip_config
      t.binary :ip_address, limit: 4
      t.integer :ip6_config
      t.binary :ip6_address, limit: 16

      t.timestamps
    end

    add_index :nics, :mac_address, unique: true
    add_index :nics, :duid, unique: true

    add_index :nics, :ip_address
    add_index :nics, :ip6_address
  end
end

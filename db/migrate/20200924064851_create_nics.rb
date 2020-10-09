class CreateNics < ActiveRecord::Migration[6.0]
  def change
    create_table :nics do |t|
      t.references :node, null: false, foreign_key: true
      t.references :network, foreign_key: true
      t.string :name
      t.integer :interface_type, null: false, default: 0
      t.string :mac_address, limit: 18
      t.string :duid
      t.integer :ip_config
      t.string :ip_address, limit: 16
      t.integer :ip6_config
      t.string :ip6_address, limit: 40

      t.timestamps
    end

    add_index :nics, :mac_address
    add_index :nics, :duid

    add_index :nics, :ip_address
    add_index :nics, :ip6_address
  end
end

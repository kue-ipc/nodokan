class CreateNics < ActiveRecord::Migration[6.0]
  def change
    create_table :nics do |t|
      t.references :node, null: false, foreign_key: true
      t.references :network, foreign_key: true
      t.string :name
      t.integer :interface_type, null: false
      t.string :mac_address, limit: 18, index: true
      t.string :duid, index: true
      t.integer :ip_config
      t.string :ip_address, limit: 16, index: true
      t.integer :ip6_config
      t.string :ip6_address, limit: 40, index: true

      t.timestamps
    end
  end
end

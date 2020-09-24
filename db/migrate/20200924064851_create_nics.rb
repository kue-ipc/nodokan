class CreateNics < ActiveRecord::Migration[6.0]
  def change
    create_table :nics do |t|
      t.references :node, null: false, foreign_key: true
      t.references :network, null: false, foreign_key: true
      t.string :name
      t.binary :mac_address
      t.binary :duid
      t.integer :ip_config
      t.binary :ip_address
      t.integer :ip6_config
      t.binary :ip6_address

      t.timestamps
    end
  end
end

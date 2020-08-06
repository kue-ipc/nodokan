class CreateIpAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :ip_addresses do |t|
      t.references :network_connection, null: false, foreign_key: true
      t.integer :config
      t.integer :ip_version
      t.string :address

      t.timestamps
    end
    add_index :ip_addresses, :address
  end
end

class CreateIpAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :ip_addresses do |t|
      t.references :network_connection, null: false, foreign_key: true
      t.references :ip_pool, foreign_key: true
      t.integer :family, null: false, default: Socket::AF_INET
      t.integer :config, null: false

      t.string :address

      t.timestamps
    end
    add_index :ip_addresses, :address
  end
end

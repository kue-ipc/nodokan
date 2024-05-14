class RemoveUniqueIndexOnIpv4Arps < ActiveRecord::Migration[7.1]
  def change
    remove_index :ipv4_arps, [:ipv4_data, :mac_address_data], unique: true
  end
end

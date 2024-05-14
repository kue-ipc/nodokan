class RemoveUniqueIndexOnIpv6Neighbors < ActiveRecord::Migration[7.1]
  def change
    remove_index :ipv6_neighbors, [:ipv6_data, :mac_address_data], unique: true
  end
end

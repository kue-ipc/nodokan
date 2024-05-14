class RenameDiscoveredAtToEndAtOnIpv6Neighbors < ActiveRecord::Migration[7.1]
  def change
    rename_column :ipv6_neighbors, :discovered_at, :end_at
  end
end

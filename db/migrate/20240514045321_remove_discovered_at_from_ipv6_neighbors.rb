class RemoveDiscoveredAtFromIpv6Neighbors < ActiveRecord::Migration[7.1]
  def change
    change_column_null :ipv6_neighbors, :discovered_at, true

    reversible do |direction|
      direction.down do
        Ipv6Neighbor.find_each do |ipv6_neighbor|
          ipv6_neighbor.update!(discovered_at: ipv6_neighbor.end_at)
        end
      end
    end

    remove_column :ipv6_neighbors, :discovered_at, :datetime
  end
end

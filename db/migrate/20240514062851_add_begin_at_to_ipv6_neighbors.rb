class AddBeginAtToIpv6Neighbors < ActiveRecord::Migration[7.1]
  def change
    add_column :ipv6_neighbors, :begin_at, :datetime

    reversible do |direction|
      direction.up do
        Ipv6Neighbor.find_each do |ipv6_neighbor|
          ipv6_neighbor.update!(begin_at: ipv6_neighbor.end_at)
        end
      end
    end

    change_column_null :ipv6_neighbors, :begin_at, false
  end
end

class AddBeginAtToIpv6Neighbors < ActiveRecord::Migration[7.1]
  def change
    add_column :ipv6_neighbors, :begin_at, :datetime
  end
end

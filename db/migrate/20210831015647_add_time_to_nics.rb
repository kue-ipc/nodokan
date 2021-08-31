class AddTimeToNics < ActiveRecord::Migration[6.1]
  def change
    add_column :nics, :ipv4_resolved_at, :datetime
    add_column :nics, :ipv6_discovered_at, :datetime
    add_column :nics, :ipv4_leased_at, :datetime
    add_column :nics, :ipv6_leased_at, :datetime
    add_column :nics, :auth_at, :datetime
  end
end

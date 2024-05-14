class RemoveResolvedAtFromIpv4Arps < ActiveRecord::Migration[7.1]
  def change
    change_column_null :ipv4_arps, :resolved_at, true

    reversible do |direction|
      direction.down do
        Ipv4Arp.find_each do |ipv4_arp|
          ipv4_arp.update!(resolved_at: ipv4_arp.last_at)
        end
      end
    end

    remove_column :ipv4_arps, :resolved_at, :datetime
  end
end

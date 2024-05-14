class AddBeginAtToIpv4Arps < ActiveRecord::Migration[7.1]
  def change
    add_column :ipv4_arps, :begin_at, :datetime

    reversible do |direction|
      direction.up do
        Ipv4Arp.find_each do |ipv4_arp|
          ipv4_arp.update!(begin_at: ipv4_arp.end_at)
        end
      end
    end

    change_column_null :ipv4_arps, :begin_at, false
  end
end

class AddBeginAtToIpv4Arps < ActiveRecord::Migration[7.1]
  def change
    add_column :ipv4_arps, :begin_at, :datetime
  end
end

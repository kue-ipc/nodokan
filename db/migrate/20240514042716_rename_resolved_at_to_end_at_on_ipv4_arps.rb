class RenameResolvedAtToEndAtOnIpv4Arps < ActiveRecord::Migration[7.1]
  def change
    rename_column :ipv4_arps, :resolved_at, :end_to
  end
end

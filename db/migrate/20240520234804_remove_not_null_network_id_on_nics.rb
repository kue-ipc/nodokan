class RemoveNotNullNetworkIdOnNics < ActiveRecord::Migration[7.1]
  def change
    change_column_null :nics, :network_id, true
  end
end

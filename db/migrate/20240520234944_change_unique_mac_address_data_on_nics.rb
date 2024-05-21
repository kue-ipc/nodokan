class ChangeUniqueMacAddressDataOnNics < ActiveRecord::Migration[7.1]
  def change
    remove_index :nics, :mac_address_data, unique: true
    add_index :nics, :mac_address_data
    add_index :nics, [:network_id, :mac_address_data], unique: true
  end
end

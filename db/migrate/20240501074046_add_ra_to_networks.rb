class AddRaToNetworks < ActiveRecord::Migration[7.1]
  def change
    add_column :networks, :ra, :integer, null: false, default: -1
  end
end

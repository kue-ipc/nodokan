class RemoveSpecificFromNetworks < ActiveRecord::Migration[8.1]
  def change
    remove_column :networks, :specific, :boolean, null: false, default: false
  end
end

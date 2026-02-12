class AddDeletionRelatedFlagsToNetworks < ActiveRecord::Migration[8.1]
  def change
    add_column :networks, :disabled, :boolean, null: false, default: false
    add_column :networks, :unverifiable, :boolean, null: false, default: false
  end
end

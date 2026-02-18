class AddDeletionRelatedFlagsToNodes < ActiveRecord::Migration[8.1]
  def change
    add_column :nodes, :disabled, :boolean, null: false, default: false
    add_column :nodes, :permanent, :boolean, null: false, default: false
  end
end

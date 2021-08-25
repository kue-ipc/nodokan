class AddPublicToNodes < ActiveRecord::Migration[6.1]
  def change
    add_column :nodes, :public, :boolean, null: false, default: false
  end
end

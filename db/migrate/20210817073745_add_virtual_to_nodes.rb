class AddVirtualToNodes < ActiveRecord::Migration[6.1]
  def change
    add_column :nodes, :virtual, :boolean, null: false, default: false
  end
end

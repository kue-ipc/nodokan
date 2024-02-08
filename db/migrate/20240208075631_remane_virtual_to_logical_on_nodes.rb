class RemaneVirtualToLogicalOnNodes < ActiveRecord::Migration[7.1]
  def change
    rename_column :nodes, :virtual, :logical
  end
end

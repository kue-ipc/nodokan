class AddNodeTypeToNodes < ActiveRecord::Migration[7.1]
  def change
    add_column :nodes, :node_type, :integer, null: false, default: 0
  end
end

class AddNoticeAndNoticedAtAndExecutionAtToNodes < ActiveRecord::Migration[8.1]
  def change
    add_column :nodes, :notice, :integer, null: false, default: 0, limit: 1
    add_column :nodes, :noticed_at, :timestamp
    add_column :nodes, :execution_at, :timestamp
  end
end

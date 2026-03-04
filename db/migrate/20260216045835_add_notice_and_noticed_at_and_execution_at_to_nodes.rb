class AddNoticeAndNoticedAtAndExecutionAtToNodes < ActiveRecord::Migration[8.1]
  def change
    add_column :nodes, :notice, :integer, limit: 1
    add_column :nodes, :noticed_at, :datetime
    add_column :nodes, :execution_at, :datetime
  end
end

class AddLimitToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :limit, :integer
  end
end

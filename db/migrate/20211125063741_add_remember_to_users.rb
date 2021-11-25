class AddRememberToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :remember_created_at, :datetime
    add_column :users, :remember_token, :string
    add_index :users, :remember_token, unique: true
  end
end

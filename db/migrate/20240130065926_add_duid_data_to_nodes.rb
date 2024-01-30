class AddDuidDataToNodes < ActiveRecord::Migration[7.1]
  def change
    add_column :nodes, :duid_data, :binary, limit: 130
    add_index :nodes, :duid_data, unique: true
  end
end

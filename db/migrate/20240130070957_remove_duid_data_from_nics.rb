class RemoveDuidDataFromNics < ActiveRecord::Migration[7.1]
  def change
    remove_index :nics, :duid_data, unique: true
    remove_column :nics, :duid_data, :binary, limit: 130
  end
end

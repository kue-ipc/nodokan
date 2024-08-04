class AddLockVersionToBulks < ActiveRecord::Migration[7.1]
  def change
    add_column :bulks, :lock_version, :integer, null: false, default: 0
  end
end

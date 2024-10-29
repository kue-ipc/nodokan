class AddDefaultToAssignments < ActiveRecord::Migration[7.2]
  def change
    add_column :assignments, :default, :boolean, null: false, default: false
  end
end

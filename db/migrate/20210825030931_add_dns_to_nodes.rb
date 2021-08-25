class AddDnsToNodes < ActiveRecord::Migration[6.1]
  def change
    add_column :nodes, :dns, :boolean, null: false, default: false
  end
end

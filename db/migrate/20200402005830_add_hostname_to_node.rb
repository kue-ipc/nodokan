class AddHostnameToNode < ActiveRecord::Migration[6.0]
  def change
    add_column :nodes, :hostname, :string
    add_column :nodes, :domain, :string
  end
end

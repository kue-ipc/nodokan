class AddSeparatedToNetworks < ActiveRecord::Migration[8.1]
  def change
    add_column :networks, :separated, :boolean, null: false, default: false
  end
end

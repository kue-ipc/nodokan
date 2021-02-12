class AddAuthNetworkToUsers < ActiveRecord::Migration[6.1]
  def change
    add_reference :users, :auth_network, foreign_key: {to_table: :networks}
  end
end

class AddNetworkToUser < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :network, null: true, foreign_key: true
  end
end

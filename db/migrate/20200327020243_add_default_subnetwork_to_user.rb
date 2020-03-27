class AddDefaultSubnetworkToUser < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :default_subnetwork, foreign_key: {to_table: :subnetworks}
  end
end

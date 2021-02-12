class CreateNetworksUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :networks_users do |t|
      t.references :network, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
    end
  end
end

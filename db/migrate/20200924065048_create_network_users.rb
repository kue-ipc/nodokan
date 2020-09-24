class CreateNetworkUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :network_users do |t|
      t.references :network, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.boolean :assignable, null: false, default: false
      t.boolean :managable, null: false, default: false
      t.boolean :assigned, null: false, default: false

      t.timestamps
    end
    add_index :network_users, [:network_id, :user_id], unique: true
  end
end

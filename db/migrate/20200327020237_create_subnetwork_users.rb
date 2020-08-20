class CreateSubnetworkUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :subnetwork_users do |t|
      t.references :subnetwork, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.boolean :assignable, null: false, default: false
      t.boolean :managable, null: false, default: false
      t.boolean :default, null: false, default: false

      t.timestamps
    end
  end
end

class CreateSubnetworkUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :subnetwork_users do |t|
      t.references :subnetwork, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.boolean :assignable
      t.boolean :managable

      t.timestamps
    end
  end
end

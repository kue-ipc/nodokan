class CreateAssignments < ActiveRecord::Migration[6.1]
  def change
    create_table :assignments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :network, null: false, foreign_key: true
      t.boolean :auth, null: false, deafult: false
      t.boolean :use, null: false, deafult: false
      t.boolean :manage, null: false, deafult: false

      t.timestamps
    end
    add_index :assignments, [:user_id, :network_id], unique: true
  end
end

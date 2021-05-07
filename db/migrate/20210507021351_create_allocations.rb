class CreateAllocations < ActiveRecord::Migration[6.1]
  def change
    create_table :allocations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :network, null: false, foreign_key: true
      t.boolean :admin, null: false, deafult: false
      t.boolean :usable, null: false, deafult: false
      t.boolean :auth, null: false, deafult: false

      t.timestamps
    end
  end
end

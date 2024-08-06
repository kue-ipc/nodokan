class CreateBulks < ActiveRecord::Migration[7.1]
  def change
    create_table :bulks do |t|
      t.references :user, foreign_key: true
      t.string :target, null: false
      t.integer :status, null: false
      t.integer :number, null: false, default: 0
      t.integer :success, null: false, default: 0
      t.integer :failure, null: false, default: 0

      t.timestamps
    end
  end
end

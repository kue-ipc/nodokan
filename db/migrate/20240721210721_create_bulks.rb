class CreateBulks < ActiveRecord::Migration[7.1]
  def change
    create_table :bulks do |t|
      t.references :user, foreign_key: true
      t.string :model, null: false
      t.integer :status, null: false
      t.timestamp :started_at
      t.timestamp :stopped_at

      t.timestamps
    end
  end
end

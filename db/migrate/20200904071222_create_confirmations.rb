class CreateConfirmations < ActiveRecord::Migration[6.0]
  def change
    create_table :confirmations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :node, null: false, foreign_key: true
      t.integer :existence, null: false
      t.integer :content, null: false
      t.integer :os_update, null: false
      t.integer :ms_upadte, null: false
      t.integer :store_update, null: false
      t.integer :soft_update, null: false
      t.integer :securiyt_update, null: false
      t.date :updated_date, null: false
      t.references :securiy_software, foreign_key: true

      t.timestamps
    end
  end
end

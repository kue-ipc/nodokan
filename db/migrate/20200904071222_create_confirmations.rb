class CreateConfirmations < ActiveRecord::Migration[6.0]
  def change
    create_table :confirmations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :node, null: false, foreign_key: true
      t.references :security_software, foreign_key: true
      t.integer :existence, null: false
      t.integer :content, null: false
      t.integer :os_update, null: false
      t.integer :app_upadte, null: false
      t.integer :security_update, null: false
      t.integer :security_scan, null: false

      t.boolean :approved

      t.timestamps
    end
  end
end

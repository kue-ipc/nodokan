class CreateConfirmations < ActiveRecord::Migration[6.0]
  def change
    create_table :confirmations do |t|
      t.references :node, null: false, index: {unique: true}, foreign_key: true
      t.references :security_software, foreign_key: true
      t.integer :existence, null: false
      t.integer :content, null: false
      t.integer :os_update, null: false
      t.integer :app_update, null: false
      t.integer :security_update, null: false
      t.integer :security_scan, null: false

      t.timestamp :confirmed_at, null: false
      t.timestamp :expiration, null: false
      t.boolean :approved, null: false, default: false

      t.timestamps
    end
  end
end

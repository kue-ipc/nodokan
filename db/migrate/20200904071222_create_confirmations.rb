class CreateConfirmations < ActiveRecord::Migration[6.0]
  def change
    create_table :confirmations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :node, null: false, foreign_key: true
      t.integer :existence
      t.integer :registered_content
      t.integer :os_update
      t.integer :ms_upadte
      t.integer :store_update
      t.string :soft_update,
      t.date :updated_date
      t.integer :securiy_software
      t.string :security_software_name
      t.integer :securiyt_software_update

      t.timestamps
    end
  end
end

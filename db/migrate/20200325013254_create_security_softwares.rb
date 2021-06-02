class CreateSecuritySoftwares < ActiveRecord::Migration[6.0]
  def change
    create_table :security_softwares do |t|
      t.references :os_category, null: false, foreign_key: true

      t.integer :installation_method, null: false, index: true, limit: 1

      t.string  :name, null: false, index: true

      t.boolean :approved, null: false, default: false
      t.boolean :confirmed, null: false, default: false
      t.text :description

      t.integer :confirmations_count, null: false, default: 0

      t.timestamps
    end
    add_index :security_softwares,
      [:os_category_id, :installation_method, :name],
      name: :security_softoware_name, unique: true
  end
end

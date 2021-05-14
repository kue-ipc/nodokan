class CreateOperatingSystems < ActiveRecord::Migration[6.0]
  def change
    create_table :operating_systems do |t|
      t.references :os_category, null: false, foreign_key: true

      t.string :name, null: false, index: true

      t.date :eol
      t.boolean :approved, null: false, default: false
      t.boolean :confirmed, null: false, default: false
      t.text :description

      t.integer :nodes_count, null: false, default: 0

      t.timestamps
    end
    add_index :operating_systems, [:os_category_id, :name],
      name: :operating_system_name, unique: true
  end
end

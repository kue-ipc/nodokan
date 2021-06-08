class CreateOperatingSystems < ActiveRecord::Migration[6.0]
  def change
    create_table :operating_systems do |t|
      t.references :os_category, null: false, foreign_key: true

      t.string :name, null: false, index: { unique: true }

      t.date :eol
      t.boolean :confirmed, null: false, default: false
      t.text :description

      t.integer :nodes_count, null: false, default: 0

      t.timestamps
    end
  end
end

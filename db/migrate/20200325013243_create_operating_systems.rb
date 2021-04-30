class CreateOperatingSystems < ActiveRecord::Migration[6.0]
  def change
    create_table :operating_systems do |t|
      t.integer :os_category, null: false, index: true
      t.string  :name,        null: false, index: {unique: true}

      t.date :eol
      t.boolean :approved, null: false, default: false
      t.boolean :confirmed, null: false, default: false
      t.text :description

      t.integer :nodes_count, null: false, default: 0

      t.timestamps
    end
  end
end

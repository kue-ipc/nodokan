class CreateOsCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :os_categories do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :icon
      t.integer :order, null: false, default: 0
      t.boolean :locked, null: false, default: false
      t.text :description

      t.timestamps
    end
  end
end

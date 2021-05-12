class CreateOsCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :os_categories do |t|
      t.string :name, null: false, index: {unique: true}
      t.string :icon
      t.integer :order, null: false, default: 0
      t.text :description

      t.timestamps
    end
    add_index :os_categories, :name
  end
end

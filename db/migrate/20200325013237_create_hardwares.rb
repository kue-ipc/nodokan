class CreateHardwares < ActiveRecord::Migration[6.0]
  def change
    create_table :hardwares do |t|
      t.integer :category, null: false
      t.string :maker, null: false
      t.string :product_name, null: false
      t.string :model_number

      t.timestamps
    end
    add_index :hardwares, :maker
    add_index :hardwares, :product_name
    add_index :hardwares, :model_number
  end
end

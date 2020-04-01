class CreateHardwares < ActiveRecord::Migration[6.0]
  def change
    create_table :hardwares do |t|
      t.integer :category
      t.string :maker
      t.string :product_name
      t.string :model_number

      t.timestamps
    end
    add_index :hardwares, :maker
    add_index :hardwares, :product_name
    add_index :hardwares, :model_number
  end
end

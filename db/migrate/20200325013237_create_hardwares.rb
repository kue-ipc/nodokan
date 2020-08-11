class CreateHardwares < ActiveRecord::Migration[6.0]
  def change
    create_table :hardwares do |t|
      t.integer :category, null: false
      t.string :maker, null: false, default: ''
      t.string :product_name, null: false, default: ''
      t.string :model_number, null: false, default: ''

      t.timestamps
    end
    add_index :hardwares, :maker
    add_index :hardwares, :product_name
    add_index :hardwares, :model_number
    add_index :hardwares, [:category, :maker, :product_name, :model_number], unique: true
  end
end

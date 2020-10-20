class CreateHardwares < ActiveRecord::Migration[6.0]
  def change
    create_table :hardwares do |t|
      t.integer :device_type, null: false
      t.string :maker, null: false, default: ''
      t.string :product_name, null: false, default: ''
      t.string :model_number, null: false, default: ''

      t.integer :nodes_count, null: false, default: 0

      t.timestamps
    end
    add_index :hardwares, :maker
    add_index :hardwares, :product_name
    add_index :hardwares, :model_number
    add_index :hardwares, [:device_type, :maker, :product_name, :model_number],
      name: :hardware_model,
      unique: true
  end
end

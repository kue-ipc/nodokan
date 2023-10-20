class CreateHardwares < ActiveRecord::Migration[6.0]
  def change
    create_table :hardwares do |t|
      t.references :device_type, foreign_key: true

      t.string  :maker,        null: false, default: "", index: true
      t.string  :product_name, null: false, default: "", index: true
      t.string  :model_number, null: false, default: "", index: true

      t.boolean :confirmed, null: false, default: false

      t.integer :nodes_count, null: false, default: 0

      t.timestamps
    end
    add_index :hardwares,
      [:device_type_id, :maker, :product_name, :model_number],
      name: :hardware_model,
      unique: true
  end
end

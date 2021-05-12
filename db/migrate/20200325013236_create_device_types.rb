class CreateDeviceTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :device_types do |t|
      t.string :name, null: false, index: {unique: true}
      t.string :icon
      t.integer :order, null: false, default: 0
      t.text :description

      t.timestamps
    end
  end
end

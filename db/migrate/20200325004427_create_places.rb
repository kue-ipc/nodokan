class CreatePlaces < ActiveRecord::Migration[6.0]
  def change
    create_table :places do |t|
      t.string :area, null: false, default: ''
      t.string :building, null: false, default: ''
      t.integer :floor, null: false, default: 0
      t.string :room, null: false, default: ''
      t.boolean :confirmed, null: false, default: false

      t.integer :nodes_count, null: false, default: 0

      t.timestamps
    end
    add_index :places, :area
    add_index :places, :building
    add_index :places, :room
    add_index :places, [:area, :building, :floor, :room], unique: true
  end
end

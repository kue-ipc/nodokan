class CreatePlaces < ActiveRecord::Migration[6.0]
  def change
    create_table :places do |t|
      t.string :area
      t.string :building
      t.integer :floor
      t.string :room

      t.timestamps
    end
    add_index :places, :area
    add_index :places, :building
    add_index :places, :room
  end
end

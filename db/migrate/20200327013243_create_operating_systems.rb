class CreateOperatingSystems < ActiveRecord::Migration[6.0]
  def change
    create_table :operating_systems do |t|
      t.integer :category
      t.string :name
      t.date :eol
      t.text :description

      t.timestamps
    end
    add_index :operating_systems, :name, unique: true
  end
end

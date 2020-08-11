class CreateOperatingSystems < ActiveRecord::Migration[6.0]
  def change
    create_table :operating_systems do |t|
      t.integer :category, null: false
      t.string :name, null: false
      t.date :eol
      t.text :description

      t.timestamps
    end
    add_index :operating_systems, :name
    add_index :operating_systems, [:category, :name], unique: true
  end
end

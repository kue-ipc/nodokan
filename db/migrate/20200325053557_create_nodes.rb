class CreateNodes < ActiveRecord::Migration[6.0]
  def change
    create_table :nodes do |t|
      t.string :name, null: false
      t.references :owner, polymorphic: true
      t.timestamp :confirmed_at
      t.text :note

      t.timestamps
    end
    add_index :nodes, :name
  end
end

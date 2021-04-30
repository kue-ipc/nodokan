class CreateNodes < ActiveRecord::Migration[6.0]
  def change
    create_table :nodes do |t|
      t.references :user, foreign_key: true

      t.string :name, null: false
      t.string :hostname
      t.string :domain

      t.references :place, foreign_key: true
      t.references :hardware, foreign_key: true
      t.references :operating_system, foreign_key: true

      t.text :note

      t.timestamps
    end
    add_index :nodes, [:hostname, :domain], name: :fqdn, unique: true
  end
end

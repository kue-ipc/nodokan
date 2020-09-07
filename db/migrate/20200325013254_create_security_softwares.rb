class CreateSecuritySoftwares < ActiveRecord::Migration[6.0]
  def change
    create_table :security_softwares do |t|
      t.integer :category, null: false
      t.integer :operating_system_category, null: false
      t.string :name, null: false
      t.date :eol
      t.text :description

      t.timestamps
    end
    add_index :security_softwares, [:category, :operating_system_category]
    add_index :security_softwares, :name, unique: true
  end
end

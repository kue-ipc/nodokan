class CreateSecuritySoftwares < ActiveRecord::Migration[6.0]
  def change
    create_table :security_softwares do |t|
      t.integer :state, null: false
      t.integer :os_category, null: false
      t.string :name, null: false
      t.boolean :approved, null: false
      t.text :description

      t.timestamps
    end
    add_index :security_softwares, :name
    add_index :security_softwares, [:state, :os_category]
    add_index :security_softwares, [:state, :os_category, :name], unique: true
  end
end

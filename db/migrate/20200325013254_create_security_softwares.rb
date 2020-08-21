class CreateSecuritySoftwares < ActiveRecord::Migration[6.0]
  def change
    create_table :security_softwares do |t|
      t.string :name, null: false
      t.text :description

      t.integer :nodes_count, null: false, default: 0

      t.timestamps
    end
    add_index :security_softwares, :name, unique: true
  end
end

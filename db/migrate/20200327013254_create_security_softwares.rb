class CreateSecuritySoftwares < ActiveRecord::Migration[6.0]
  def change
    create_table :security_softwares do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
    add_index :security_softwares, :name, unique: true
  end
end

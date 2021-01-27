class CreateSecuritySoftwares < ActiveRecord::Migration[6.0]
  def change
    create_table :security_softwares do |t|
      t.integer :installation_method, null: false, index: true
      t.integer :os_category, null: false, index: true
      t.string :name, null: false, index: true
      t.boolean :approved, null: false, default: false
      t.boolean :confirmed, null: false, default: false
      t.text :description

      t.integer :confirmations_count, null: false, default: 0

      t.timestamps
    end
    add_index :security_softwares,
      [:installation_method, :os_category, :name],
      name: :security_softoware_name,
      unique: true
  end
end

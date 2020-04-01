class CreateNetworkCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :network_categories do |t|
      t.string :name, null: false
      t.boolean :dhcp, null: false, default: false
      t.boolean :auth, null: false, default: false
      t.boolean :global, null: false, default: false

      t.timestamps
    end
    add_index :network_categories, :name, unique: true
  end
end

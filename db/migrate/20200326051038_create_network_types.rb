class CreateNetworkTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :network_types do |t|
      t.string :name, null: false
      t.boolean :dhcp, null: false, default: false
      t.boolean :auth, null: false, default: false
      t.boolean :managed, null: false, default: false

      t.timestamps
    end

    add_index :network_types, :name, unique: true
  end
end

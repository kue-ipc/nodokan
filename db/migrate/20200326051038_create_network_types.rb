class CreateNetworkTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :network_types do |t|
      t.string :name
      t.boolean :dhcp
      t.boolean :auth
      t.boolean :managed

      t.timestamps
    end
  end
end

class CreateNetworkOptions < ActiveRecord::Migration[7.1]
  def change
    create_table :network_options do |t|
      t.references :network, null: false, foreign_key: true
      t.string :type, null: false
      t.json :data, null: false

      t.timestamps
    end
  end
end

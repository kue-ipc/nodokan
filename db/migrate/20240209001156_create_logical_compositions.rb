class CreateLogicalCompositions < ActiveRecord::Migration[7.1]
  def change
    create_table :logical_compositions do |t|
      t.references :node, null: false, foreign_key: true
      t.references :component, null: false, foreign_key: {to_table: :nodes}

      t.timestamps
    end
  end
end

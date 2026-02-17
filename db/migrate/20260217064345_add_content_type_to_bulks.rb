class AddContentTypeToBulks < ActiveRecord::Migration[8.1]
  def change
    add_column :bulks, :content_type, :string, null: false, default: "text/csv"
    change_column_default :bulks, :content_type, from: "text/csv", to: nil
  end
end

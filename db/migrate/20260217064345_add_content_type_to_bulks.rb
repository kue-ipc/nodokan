class AddContentTypeToBulks < ActiveRecord::Migration[8.1]
  def change
    # set default value to avoid error when validating existing records
    add_column :bulks, :content_type, :string, default: "text/csv"
    change_column_default :bulks, :content_type, from: "text/csv", to: nil
  end
end

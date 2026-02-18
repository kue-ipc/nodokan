class AddContentTypeToBulks < ActiveRecord::Migration[8.1]
  def change
    add_column :bulks, :content_type, :string
  end
end

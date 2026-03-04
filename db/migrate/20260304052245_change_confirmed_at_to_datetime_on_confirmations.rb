class ChangeConfirmedAtToDatetimeOnConfirmations < ActiveRecord::Migration[8.1]
  def up
    change_column :confirmations, :confirmed_at, :datetime, null: true, default: nil
  end

  def down
    change_column :confirmations, :confirmed_at, :timestamp, null: false
  end
end

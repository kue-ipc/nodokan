class RemoveExpirationFromConfirmations < ActiveRecord::Migration[8.1]
  def change
    # NOTE: Duaring rollback, all confirmations will expire because all expirations are now.
    change_column_default :confirmations, :expiration, from: nil, to: -> { 'CURRENT_TIMESTAMP' }
    remove_column :confirmations, :expiration, :timestamp, null: false, default: -> { 'CURRENT_TIMESTAMP' }
  end
end

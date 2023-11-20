class AddSoftwareAndSecurityHardwareToConfirmations < ActiveRecord::Migration[7.0]
  def change
    add_column :confirmations, :software, :integer, limit: 1, null: false, default: -1
    add_column :confirmations, :security_hardware, :integer, null: false, default: -1
    change_column_default :confirmations, :existence, from: nil, to: -1
    change_column_default :confirmations, :content, from: nil, to: -1
    change_column_default :confirmations, :os_update, from: nil, to: -1
    change_column_default :confirmations, :app_update, from: nil, to: -1
    change_column_default :confirmations, :security_update, from: nil, to: -1
    change_column_default :confirmations, :security_scan, from: nil, to: -1
  end
end

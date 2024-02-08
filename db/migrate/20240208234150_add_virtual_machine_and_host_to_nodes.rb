class AddVirtualMachineAndHostToNodes < ActiveRecord::Migration[7.1]
  def change
    add_column :nodes, :virtual_machine, :boolean, null: false, default: false
    add_reference :nodes, :host, foreign_key: {to_table: :nodes}
  end
end

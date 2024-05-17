class RemoveLogicalAndVirtualMachineFromNodes < ActiveRecord::Migration[7.1]
  def change
    remove_column :nodes, :logical, :boolean, default: false, null: false
    remove_column :nodes, :virtual_machine, :boolean, default: false,
      null: false
  end
end

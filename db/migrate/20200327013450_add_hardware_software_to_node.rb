class AddHardwareSoftwareToNode < ActiveRecord::Migration[6.0]
  def change
    add_reference :nodes, :hardware, foreign_key: true
    add_reference :nodes, :operating_system, foreign_key: true
    add_reference :nodes, :security_software, foreign_key: true
  end
end

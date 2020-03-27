class AddLocationToNode < ActiveRecord::Migration[6.0]
  def change
    add_reference :nodes, :location, polymorphic: true
  end
end

class ChangeFlagsToNodeTypeOnNodes < ActiveRecord::Migration[7.1]
  def up
    # virtualとlogical両方はないが、両方の場合はlogicalを優先する。
    # virtual_machine => node_type: virtual
    execute <<-SQL.squish
      UPDATE nodes
      SET node_type = 2
      WHERE virtual_machine = TRUE;
    SQL
    # logical => node_type: logical
    execute <<-SQL.squish
      UPDATE nodes
      SET node_type = 3
      WHERE logical = TRUE;
    SQL
  end

  def down
    # node_type: virtual_machine => logical
    execute <<-SQL.squish
      UPDATE nodes
      SET virtual_machine = TRUE
      WHERE node_type = 2;
    SQL
    # node_type: logical => logical
    execute <<-SQL.squish
      UPDATE nodes
      SET logical = TRUE
      WHERE node_type = 3;
    SQL
  end
end

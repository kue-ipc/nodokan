class ChangeTargetToUnderscoreOnBulks < ActiveRecord::Migration[8.1]
  def up
    # Node
    execute <<-SQL.squish
      UPDATE bulks
      SET target = 'node'
      WHERE target = 'Node';
    SQL
    # Confirmation
    execute <<-SQL.squish
      UPDATE bulks
      SET target = 'confirmation'
      WHERE target = 'Confirmation';
    SQL
    # Network
    execute <<-SQL.squish
      UPDATE bulks
      SET target = 'network'
      WHERE target = 'Network';
    SQL
    # User
    execute <<-SQL.squish
      UPDATE bulks
      SET target = 'user'
      WHERE target = 'User';
    SQL
  end

  def down
    # node
    execute <<-SQL.squish
      UPDATE bulks
      SET target = 'Node'
      WHERE target = 'node';
    SQL
    # confirmation
    execute <<-SQL.squish
      UPDATE bulks
      SET target = 'Confirmation'
      WHERE target = 'confirmation';
    SQL
    # netowrk
    execute <<-SQL.squish
      UPDATE bulks
      SET target = 'Network'
      WHERE target = 'network';
    SQL
    # user
    execute <<-SQL.squish
      UPDATE bulks
      SET target = 'User'
      WHERE target = 'user';
     SQL
  end
end

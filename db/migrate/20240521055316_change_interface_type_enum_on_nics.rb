class ChangeInterfaceTypeEnumOnNics < ActiveRecord::Migration[7.1]
  # 使うことはないbluetooth(2)とdialup(4)をなくす
  # vpnの番号を5から9へ変更

  def up
    # interface_type: bluoutooth(2) or dialup(4) => other(127)
    execute <<-SQL.squish
      UPDATE nics
      SET interface_type = 127
      WHERE interface_type = 2 OR interface_type = 4;
    SQL
    # interface_type: vpn(5) => vpn(9)
    execute <<-SQL.squish
      UPDATE nics
      SET interface_type = 9
      WHERE interface_type = 5;
    SQL
  end

  def down
    # interface_type: vpn(9) => vpn(5)
    execute <<-SQL.squish
      UPDATE nics
      SET interface_type = 5
      WHERE interface_type = 9;
    SQL
  end
end

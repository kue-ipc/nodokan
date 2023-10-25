module Radius
  class Radgroupreply < RadiusRecord
    self.table_name = "radgroupreply_alt"
    # NOTE: VIEWテーブルの場合はprimary_keyの指定が必須
    self.primary_key = "id"
  end
end

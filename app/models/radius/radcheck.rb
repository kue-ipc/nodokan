module Radius
  class Radcheck < RadiusRecord
    self.table_name = "radcheck_alt"
    # NOTE: VIEWテーブルの場合はprimary_keyの指定が必須
    self.primary_key = "id"
  end
end

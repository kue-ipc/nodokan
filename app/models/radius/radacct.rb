module Radius
  class Radacct < RadiusRecord
    include CleanRecord

    self.table_name = "radacct"
    self.primary_key = "radacctid"
  end
end

module Radius
  class Radacct < RadiusRecord
    self.table_name = 'radacct'
    self.primary_key = 'radacctid'
  end
end

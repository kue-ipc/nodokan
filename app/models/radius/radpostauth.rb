module Radius
  class Radpostauth < RadiusRecord
    include CleanRecord

    self.table_name = "radpostauth"
  end
end

module Radius
  class Nas < RadiusRecord
    self.table_name = "nas"
    # type attribute is not an inheritence column
    self.inheritance_column = "inheritance_type"
  end
end

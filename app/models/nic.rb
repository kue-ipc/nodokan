class Nic < ApplicationRecord
  belongs_to :node
  belongs_to :network




  def mac_gl?
    @mac_address[0].ord & 0x02
  end

end

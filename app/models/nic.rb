class Nic < ApplicationRecord
  include IpConfig
  include Ip6Config

  belongs_to :node
  belongs_to :network




  def mac_gl?
    @mac_address[0].ord & 0x02
  end

end

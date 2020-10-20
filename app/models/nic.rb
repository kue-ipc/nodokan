class Nic < ApplicationRecord
  include IpConfig
  include Ip6Config

  belongs_to :node
  belongs_to :network

  enum interface_type: {
    wired: 0,
    wireless: 1,
    virtual: 2,
    bluetooth: 3,
    dialup: 4,
    vpn: 5,
    other: 255,
    unknown: -1,
  }

  def mac_gl?
    @mac_address[0].ord & 0x02
  end
end

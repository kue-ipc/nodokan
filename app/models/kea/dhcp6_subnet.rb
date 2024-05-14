module Kea
  class Dhcp6Subnet < KeaRecord
    self.table_name = "dhcp6_subnet"
    self.primary_key = "subnet_id"

    has_many :dhcp6_pools, foreign_key: "subnet_id", primary_key: "subnet_id",
      dependent: :destroy, inverse_of: :dhcp6_subnet
    has_many :hosts, primary_key: "subnet_id",
      dependent: :nullify, inverse_of: :dhcp6_subnet
    has_many :dhcp6_subnet_servers, foreign_key: "subnet_id",
      primary_key: "subnet_id", dependent: :destroy, inverse_of: :dhcp6_subnet

    # subnetはscope_idが1
    has_many :dhcp6_options, -> { where(scope_id: 1) },
      primary_key: "subnet_id",
      dependent: :destroy, inverse_of: :dhcp6_subnet

    has_many :dhcp6_servers, through: :dhcp6_subnet_servers

    def name
      subnet_prefix
    end

    def ipv6
      IPAddr.new(subnet_prefix)
    end
  end
end

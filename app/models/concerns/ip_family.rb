module IpFamily
  extend ActiveSupport::Concern

  included do
    enum family: {
      ipv4: Socket::AF_INET,
      ipv6: Socket::AF_INET6,
    }
  end
end

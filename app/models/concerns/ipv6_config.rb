module Ipv6Config
  extend ActiveSupport::Concern

  included do
    enum ipv6_config: {
      dynamic: 0,
      reserved: 1,
      static: 2,
      mapped: 4,
      manual: 8,
      disabled: -1,
    }, _prefix: :ipv6
  end
end

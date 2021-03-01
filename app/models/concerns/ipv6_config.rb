module Ipv6Config
  extend ActiveSupport::Concern

  included do
    enum ipv6_config: {
      dynamic: 0,
      reserved: 1,
      static: 2,
      link_local: 8,
      manual: 9,
      disabled: -1,
    }, _prefix: :ipv6
  end
end

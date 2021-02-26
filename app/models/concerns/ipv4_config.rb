module Ipv4Config
  extend ActiveSupport::Concern

  included do
    enum ipv4_config: {
      dynamic: 0,
      reserved: 1,
      static: 2,
      link_local: 8,
      manual: 9,
      disabled: 255,
    }, _prefix: :ipv4
  end
end

module Ipv4Config
  extend ActiveSupport::Concern

  included do
    enum ipv4_config: {
      dynamic: 0,
      reserved: 1,
      static: 2,
      manual: 8,
      disabled: -1,
    }, _prefix: :ipv4
  end
end

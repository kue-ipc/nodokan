module Ip6Config
  extend ActiveSupport::Concern

  included do
    enum ip6_config: {
      dynamic: 0,
      reserved: 1,
      static: 2,
      link_local: 8,
      manual: 9,
      disabled: 255,
    }, _prefix: :ip6
  end
end

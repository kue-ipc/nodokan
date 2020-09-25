module Ip6Config
  extend ActiveSupport::Concern

  included do
    enum ip6_config: {
      disabled: 0,
      static: 1,
      dynamic: 2,
      reserved: 3,
      link_local: 4,
    }
  end
end

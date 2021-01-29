module IpConfig
  extend ActiveSupport::Concern

  included do
    enum ip_config: {
      disabled: 0,
      static: 1,
      dynamic: 2,
      reserved: 3,
      link_local: 4,
      manual: 5,
    }, _prefix: :ip
  end
end

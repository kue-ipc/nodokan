module IpConfig
  extend ActiveSupport::Concern

  included do
    enum config: {
      static: 0,
      dynamic: 1,
      reserved: 2,
    }
  end
end

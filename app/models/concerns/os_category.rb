module OsCategory
  extend ActiveSupport::Concern

  included do
    enum os_category: {
      windows_client: 0,
      windows_server: 1,
      mac: 4,
      apple: 16,
      android: 17,
      linux: 8,
      bsd: 9,
      unix: 10,
      dedicated: 128,
      embedded: 129,
      other: 130,
      less: 192,
      unknown: 255,
    }, _prefix: :os
  end
end

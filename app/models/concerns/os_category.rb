module OsCategory
  extend ActiveSupport::Concern

  included do
    enum os_category: {
      windows_client: 0,
      windows_server: 1,
      mac: 4,
      linux: 8,
      bsd: 9,
      unix: 10,
      apple: 16,
      android: 17,
      dedicated: 128,
      embedded: 129,
      os_less: 130,
      other: 255,
      unknown: -1,
    }
  end
end
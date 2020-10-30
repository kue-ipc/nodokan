class SecuritySoftware < ApplicationRecord
  include OsCategory

  enum state: {
    built_in: 0,
    distributed: 1,
    purchased: 2,
    free: 3,
    pre_installed: 4,
    unnecessary: 8,
    not_installed: 16,
    unknown: -1,
  }, _prefix: true
end

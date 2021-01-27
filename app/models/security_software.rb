class SecuritySoftware < ApplicationRecord
  include OsCategory

  enum installation_method: {
    unnecessary: 8,
    built_in: 0,
    distributed: 1,
    purchased: 2,
    free: 3,
    pre_installed: 4,
    not_installed: 16,
    unknown: 255,
  }, _prefix: true

  def self.conf_installation_methods
    @@conf_installation_methods ||= {
      unnecessary: {},
      built_in: {
        name_required: true,
        updatable: true,
        scanable: true,
      },
      distributed: {
        name_required: true,
        updatable: true,
        scanable: true,
      },
      purchased: {
        addable: true,
        name_required: true,
        updatable: true,
        scanable: true,
      },
      free: {
        updatable: true,
        scanable: true,
        name_required: true,
        addable: true,
      },
      pre_installed: {
        updatable: true,
        scanable: true,
        name_required: true,
        addable: true,
      },
      not_installed: {},
      unknown: {},
    }
  end
end

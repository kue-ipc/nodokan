class SecuritySoftware < ApplicationRecord
  belongs_to :os_category

  has_many :confirmations

  enum installation_method: {
    unnecessary: 8,
    built_in: 0,
    distributed: 1,
    purchased: 2,
    free: 3,
    pre_installed: 4,
    not_installed: 16,
    other: 255,
    unknown: -1,
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

  def os_category_name
    @os_category_name ||= os_category&.name
  end

  def os_category_name=(str)
    if str.present?
      self.os_category = OsCategory.find_or_initialize_by(name: str)
      @os_category_name = os_category&.name
    else
      self.device_type = nil
      @device_type_name = nil
    end
  end
end

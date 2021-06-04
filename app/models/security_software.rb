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
    other: 127,
    unknown: -1,
  }, _prefix: true

  before_save :auto_approve

  def os_category_name
    @os_category_name ||= os_category&.name
  end

  def os_category_name=(str)
    if str.present?
      self.os_category = OsCategory.find_by!(name: str)
      @os_category_name = os_category&.name
    else
      self.device_type = nil
      @device_type_name = nil
    end
  end

  def conf
    SecuritySoftware.conf_installation_methods[installation_method]
  end

  def auto_approve
    if !confirmed && conf[:auto_approve]
      self.approved = true
    end
  end

  # class method
  def self.conf_installation_methods
    @@conf_installation_methods ||= {
      unnecessary: {
        locked: true,
      },
      built_in: {
        locked: true,
        required: true,
        updatable: true,
        scanable: true,
      },
      distributed: {
        locked: true,
        required: true,
        updatable: true,
        scanable: true,
      },
      purchased: {
        required: true,
        updatable: true,
        scanable: true,
        auto_approve: true,
      },
      free: {
        required: true,
        updatable: true,
        scanable: true,
        auto_approve: true,
      },
      pre_installed: {
        required: true,
        updatable: true,
        scanable: true,
        auto_approve: true,
      },
      not_installed: {
        locked: true,
      },
      other: {
        required: true,
      },
      unknown: {
        locked: true,
      },
    }.with_indifferent_access
  end
end

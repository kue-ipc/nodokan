class ConfirmationsProcessor < ApplicationProcessor
  include ConfirmationParameter

  # NOTE: Use node instead of confirmation
  model_name "Node"

  keys [
    :name,
    :address,
    :os_category,
    :status,
    :existence,
    :content,
    :os_update,
    :app_update,
    :software,
    {security_hardwares: []},
    {security_software: [:installation_method, :name]},
    :security_update,
    :security_scan,
  ]

  converter :name, set: ->(record, value) { }

  converter :address,
    get: ->(record) {
      if record.domain.present?
        record.fqdn
      elsif (nic = record.nics.find(&:has_ipv4?))
        nic.ipv4_address
      elsif (nic = record.nics.find(&:has_ipv6?))
        nic.ipv6_address
      elsif (nic = record.nics.find(&:has_mac_address?))
        nic.mac_address
      elsif record.duid.present?
        record.duid
      else
        ""
      end
    },
    set: ->(record, value) { }

  converter :os_category,
    get: ->(record) { record.operating_system&.os_category&.name },
    set: ->(record, value) { }

  converter :status,
    get: ->(record) { record.confirmation_status },
    set: ->(record, value) { }

  converter :existence,
    get: ->(record) { record.confirmation_or_build.existence },
    set: ->(record, value) { record.confirmation_or_build.existence = value }

  converter :content,
    get: ->(record) { record.confirmation_or_build.content },
    set: ->(record, value) { record.confirmation_or_build.content = value }

  converter :os_update,
    get: ->(record) { record.confirmation_or_build.os_update },
    set: ->(record, value) { record.confirmation_or_build.os_update = value }

  converter :app_update,
    get: ->(record) { record.confirmation_or_build.app_update },
    set: ->(record, value) { record.confirmation_or_build.app_update = value }

  converter :software,
    get: ->(record) { record.confirmation_or_build.software },
    set: ->(record, value) { record.confirmation_or_build.software = value }

  converter :security_update,
    get: ->(record) { record.confirmation_or_build.security_update },
    set: ->(record, value) { record.confirmation_or_build.security_update = value }

  converter :security_scan,
    get: ->(record) { record.confirmation_or_build.security_scan },
    set: ->(record, value) { record.confirmation_or_build.security_scan = value }

  converter :security_hardwares,
    get: ->(record) { record.confirmation_or_build.security_hardwares },
    set: ->(record, value) {
      record.confirmation_or_build.security_hardware = Confirmation.security_hardware_list_to_bitwise(value)
    }

  converter :security_software,
    get: ->(record) { record.confirmation_or_build.security_software },
    set: ->(record, value) {
      return unless record.operating_system

      security_software_params = {os_category_id: record.operating_system.os_category_id, **value}
      record.confirmation_or_build.security_software =
        find_or_new_security_software(security_software_params, record.confirmation_or_build.security_software)
    }

  def create(params)
    raise "Not allowed to create confirmation"
  end

  def update(id, params)
    user_process(id, __method__) do |record|
      record.transaction do
        assign_params(record, params)
        record.confirmation_or_build.security_software = nil unless record.operating_system
        record.confirmation_or_build.approve!
        record.confirmation_or_build.save!
      end
    end
  end

  def destroy(id)
    raise "Not allowed to destroy confirmation"
  end
end

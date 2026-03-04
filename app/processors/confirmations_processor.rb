class ConfirmationsProcessor < ApplicationProcessor
  include ConfirmationParameter

  # NOTE: Use node instead of confirmation
  model_name "Node"

  keys [
    :name,
    :address,
    :status,
    :existence,
    :content,
    :os_update,
    :app_update,
    :software,
    :security_update,
    :security_scan,
    security_hardwares: [],
    security_software: [:installation_method, :name],
  ]

  converter :name, set: ->(record, value) { }

  converter :address,
    get: ->(record) {
      (record.fqdn if record.domain.present?) ||
        record.nics.find(&:has_ipv4?)&.ipv4_address ||
        record.nics.find(&:has_ipv6?)&.ipv6_address ||
        record.nics.find(&:has_mac_address?)&.mac_address ||
        # record.duid ||
        ""
    },
    set: ->(record, value) { }

  converter :status,
    get: ->(record) { record.solid_confirmation.status },
    set: ->(record, value) { }

  converter :existence,
    get: ->(record) { record.solid_confirmation.existence },
    set: ->(record, value) { record.solid_confirmation.existence = value }

  converter :content,
    get: ->(record) { record.solid_confirmation.content },
    set: ->(record, value) { record.solid_confirmation.content = value }

  converter :os_update,
    get: ->(record) { record.solid_confirmation.os_update },
    set: ->(record, value) { record.solid_confirmation.os_update = value }

  converter :app_update,
    get: ->(record) { record.solid_confirmation.app_update },
    set: ->(record, value) { record.solid_confirmation.app_update = value }

  converter :software,
    get: ->(record) { record.solid_confirmation.software },
    set: ->(record, value) { record.solid_confirmation.software = value }

  converter :security_update,
    get: ->(record) { record.solid_confirmation.security_update },
    set: ->(record, value) { record.solid_confirmation.security_update = value }

  converter :security_scan,
    get: ->(record) { record.solid_confirmation.security_scan },
    set: ->(record, value) { record.solid_confirmation.security_scan = value }

  converter :security_hardwares,
    get: ->(record) { record.solid_confirmation.security_hardwares },
    set: ->(record, value) {
      record.solid_confirmation.security_hardware = Confirmation.security_hardware_list_to_bitwise(value)
    }

  converter security_software: [:installation_method, :name],
    get: ->(record) { record.solid_confirmation.security_software },
    set: ->(record, value) {
      return unless record.operating_system

      security_software_params = {os_category_id: record.operating_system.os_category_id, **value}
      record.solid_confirmation.security_software =
        find_or_new_security_software(security_software_params, record.solid_confirmation.security_software)
    }

  def create(params)
    raise "Not allowed to create confirmation"
  end

  def update(id, params)
    user_process(id, __method__) do |record|
      record.transaction do
        assign_params(params, record:)
        solid_confirmation.security_software = nil unless record.operating_system
        record.solid_confirmation.approve!
        record.save!
      end
    end
  end

  def destroy(id)
    raise "Not allowed to destroy confirmation"
  end
end

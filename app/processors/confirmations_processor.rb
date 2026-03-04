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
    set: ->(record, value) { record.solid_confirmation.status = value }

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

  # TODO: ここはまだ書いてない
  converter security_software: [:installation_method, :name],
    get: ->(record) {
      software = record.solid_confirmation.security_software
      if software.present?
        {
          installation_method: software.installation_method,
          name: software.name,
        }
      end
    },
    set: ->(record, value) {
      if value.present?
        software = record.solid_confirmation.build_security_software
        software.installation_method = value[:installation_method]
        software.name = value[:name]
      else
        record.solid_confirmation.security_software&.mark_for_destruction
      end
    }

  def create(params)
    raise "Not allowed to create confirmation"
  end

  def update(id, params)
    # TODO: ここはまだ書いてない
  end

  def destroy(id)
    raise "Not allowed to destroy confirmation"
  end
end

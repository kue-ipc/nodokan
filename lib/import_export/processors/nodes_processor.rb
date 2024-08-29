require "import_export/processors/application_processor"

module ImportExport
  module Processors
    class NodesProcessor < ApplicationProcessor
      include NodeParameter

      class_name "Node"

      params_permit(
        :user, :name, :fqdn, :type, :flag,
        {components: []}, :host, {
          place: [:area, :building, :floor, :room],
          hardware: [:device_type, :maker, :product_name, :model_number],
          operating_system: [:os_category, :name],
        }, :duid, {nics: [
          :number, :name, :interface_type, :network, :flag, :mac_address,
          :ipv4_config, :ipv4_address, :ipv6_config, :ipv6_address,
        ]}, :note)

      converter :type, :node_type

      converter :user, set: ->(record, value) {
        return unless current_user.nil? || current_user.admin?

        record.user = User.find_identifier(value)
      }

      converter :flag, set: ->(record, value) {
        return unless current_user.nil? || current_user.admin?

        record.flag = value
      }

      converter :host, set: ->(record, value) {
        record.host = Node.find_identifier(value)
      }

      converter :components, set: ->(record, value) {
        record.components = value.map(&Node.method(:find_identifier))
      }

      converter :place, set: ->(record, value) {
        record.place = find_or_new_place(value, record.place)
      }

      converter :hardware, set: ->(record, value) {
        record.hardware = find_or_new_hardware(value, record.hardware)
      }

      converter :operating_system, set: ->(record, value) {
        record.operating_system =
          find_or_new_operating_system(value, record.operating_system)
      }

      converter :nics, set: ->(record, value) {
        value.each do |nic_params|
          nic_params = nic_params.dup

          if nic_params[:network_id].blank? && nic_params[:network].present?
            nic_params[:network_id] =
              Network.find_identifier(nic_params[:network])
          end

          number = nic_params[:number]
          number = number.strip if number.is_a?(String)
          case number
          when nil, ""
            create_nic(record, nic_params)
          when Integer, /\A\d+\z/
            number = number.to_i
            update_nic(record, number, nic_params)
          when /\A!(\d+)\z/
            number = number.delete_prefix("!").to_i
            delete_nic(record, number)
          else
            record.errors.add(:nics,
              I18n.t("errors.messages.invalid_nic_number_field"))
          end
        end
      }

      # override
      private def initial_model_attributes
        {user_id: current_user&.id}
      end

      private def create_nic(record, nic_params)
        delete_unchangable_nic_params(nic_params)
        nic_params.slice!(:number, :name, :interface_type, :network_id, :flag,
          :mac_address, :ipv4_config, :ipv4_address, :ipv6_config, :ipv6_address)

        if record.new_record?
          record.nics.build(nic_params)
        else
          record.nics.create!(nic_params)
        end
      end

      private def update_nic(record, nic_number, nic_params)
        nic = Nic.find_by(node_id: record.id, number: nic_number)
        return create_nic(record, nic_params) if nic.nil?

        delete_unchangable_nic_params(nic_params, nic)
        nic_params.slice!(:number, :name, :interface_type, :network_id, :flag,
          :mac_address, :ipv4_config, :ipv4_address, :ipv6_config, :ipv6_address)
        nic.update!(nic_params)
      end

      private def delete_nic(record, nic_number)
        nic = Nic.find_by(node_id: record.id, number: nic_number)
        return if nic.nil?

        nic.destroy!
      end
    end
  end
end

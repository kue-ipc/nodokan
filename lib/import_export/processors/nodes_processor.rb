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
        record.user = User.find_identifier(value)
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
              Network.find_identifier(nic_params[:network]) || -1
          end

          delete_unchangable_nic_params(nic_params)

          number = params[:number]
          number = number.strip if number.is_a?(String)
          case number
          when nil, ""
            create_nic(record, params)
          when Integer, /\A\d+\z/
            number = number.to_i
            update_nic(record, number, params)
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
      def create(params)
        if current_user.nil? || current_user.admin?
          super
        else
          super(params.merge({user: current_user.username}))
        end
      end

      private def create_nic(record, params)
        if record.new_record?
          record.nics.build(params)
        else
          record.nics.create!(params)
        end
      end

      private def update_nic(record, nic_number, params)
        nic = Nic.find_by(node_id: record.id, number: nic_number)
        return create_nic(record, params) if nic.nil?

        nic.update!(params)
      end

      private def delete_nic(record, nic_number)
        nic = Nic.find_by(node_id: record.id, number: nic_number)
        return if nic.nil?

        nic.destroy!
      end
    end
  end
end

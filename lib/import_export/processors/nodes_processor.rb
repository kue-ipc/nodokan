require "import_export/processors/application_processor"

module ImportExport
  module Processors
    class NodesProcessor < ApplicationProcessor
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
        # TODO: 実装すること
        #   do nothing
        pp value
      }

      # override
      def create(params)
        user_process(params_to_record(params), :create) do |record|
          record.user ||= @user
          record.save if record.errors.empty?
        end
      end

      # override
      def row_to_record(row, record: model_class.new, keys: attrs, **opts)
        record.user = @user if record.new_record? && @user && !@user.admin?

        super(row, record: record, keys: keys & %w(
          user name fqdn type flag
          host components
          duid note
        ), **opts)

        params = row_to_params(row, keys: keys)

        if params[:place].present?
          record.place = find_or_new_place(params[:place], record.place)
        end

        if params[:hardware].present?
          hardware_params = params[:hardware].dup
          if hardware_params.key?(:device_type)
            name = hardware_params.delete(:device_type)
            device_type = DeviceType.find_by(name: name)
            if device_type.nil?
              record.errors.add("hardware[device_type]",
                I18n.t("errors.messages.not_found"))
              raise InvalidFieldError,
                "device type is not fonud by name: #{name}"
            end
            hardware_params[:device_type_id] = device_type.id
          end
          record.hardware = find_or_new_hardware(hardware_params,
            record.hardware)
        end

        if params[:operating_system].present?
          operating_system_params = params[:operating_system].dup
          if operating_system_params.key?(:os_category)
            name = operating_system_params.delete(:os_category)
            os_category = OsCategory.find_by(name: name)
            if os_category.nil?
              record.errors.add("operating_system[os_category]",
                I18n.t("errors.messages.not_found"))
              raise InvalidFieldError,
                "os category is not fonud by name: #{name}"
            end
            operating_system_params[:os_category_id] = os_category.id
          end
          record.operating_system =
            find_or_new_operating_system(operating_system_params,
              record.operating_system)
        end

        if params[:nic].present?
          nic_params = params[:nic].dup
          if nic_params.key?(:network)
            identifier = nic_params.delete(:network)
            network = Network.find_identifier(identifier)
            if network.nil?
              record.errors.add("nic[network]",
                I18n.t("errors.messages.not_found"))
              raise InvalidFieldError,
                "network is not fonud by identifier: #{identifier}"
            end
            nic_params[:network_id] = network.id
          end

          case nic_params[:number]
          when nil
            create_nic(record, nic_params)
          when /\A(\d+)\z/
            nic_number = ::Regexp.last_match(1).to_i
            update_nic(record, nic_number, nic_params)
          when /\A!(\d+)\z/
            nic_number = ::Regexp.last_match(1).to_i
            delete_nic(record, nic_number)
          else
            record.errors.add(:nic,
              I18n.t("errors.messages.invalid_nic_number_field"))
          end
        end
        record
      rescue InvalidFieldError => e
        Ralis.logger.error { e.message }
        # do nothing
        record
      end

      private def find_or_new_place(params, place = nil)
        params = {
          area: place&.area || "",
          building: place&.building || "",
          floor: place&.floor || 0,
          room: place&.room || "",
        }.merge(params)

        Place.find_or_initialize_by(params)
      end

      private def find_or_new_hardware(params, hardware = nil)
        params = params.dup
        errors = []
        if params.key?(:device_type)
          params[:device_type] = DeviceType.find_by(name: params[:device_type])
          if params[:device_type].nil?
            errors << [:device_type, I18n.t("errors.messages.not_found")]
          end
        end

        params = {
          device_type: hardware&.device_type,
          maker: hardware&.maker || "",
          product_name: hardware&.product_name || "",
          model_number: hardware&.model_number || "",
        }.merge(params)

        hardware = Hardware.find_or_initialize_by(params)
        errors.each do |error|
          hardware.errors.add(*error)
        end
        hardware
      end

      private def find_or_new_operating_system(params, operating_system = nil)
        params = params.dup
        errors = []
        if params.key?(:os_category)
          params[:os_category] = OsCategory.find_by(name: params[:os_category])
          if params[:os_category].nil?
            errors << [:os_category, I18n.t("errors.messages.not_found")]
          end
        end

        params = {
          os_category: operating_system&.os_category,
          name: operating_system&.name || "",
        }.merge(params)

        operating_system = OperatingSystem.find_or_initialize_by(params)
        errors.each do |error|
          operating_system.errors.add(*error)
        end
        operating_system
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

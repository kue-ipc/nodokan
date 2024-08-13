require "import_export/base_csv"

module ImportExport
  class NodeCsv < BaseCsv
    def model_class
      Node
    end

    ATTRS =
      %w(
        user name fqdn type flag
        host components
        place[area] place[building] place[floor] place[room]
        hardware[device_type] hardware[maker] hardware[product_name]
        hardware[model_number]
        operating_system[os_category] operating_system[name]
        duid
        nic[number] nic[name] nic[interface_type] nic[network]
        nic[flag] nic[mac_address]
        nic[ipv4_config] nic[ipv4_address]
        nic[ipv6_config] nic[ipv6_address]
        note
      ).freeze

    def attrs
      ATTRS
    end

    # override
    def delimiter
      "\n"
    end

    # override
    def split_row_record(record)
      record.nics.map { |nic| {nic: nic} }.presence || [{nic: nil}]
    end

    # override
    def row_assign(row, record, key, nic: nil, **_opts)
      case key
      when "type"
        row[key] = record.node_type
      when "nic[number]", "nic[name]", "nic[interface_type]", "nic[network]",
          "nic[flag]", "nic[mac_address]",
          "nic[ipv4_config]", "nic[ipv4_address]",
          "nic[ipv6_config]", "nic[ipv6_address]"
        if nic
          row[key] =
            value_to_field(nic.__send__(key_to_list(key).last))
        end
      else
        super
      end
    end

    # override
    def record_assign(record, row, key, **_opts)
      case key
      when "user"
        if @user.nil? || @user.admin?
          record.user = User.find_by(username: row["user"])
        end
      when "type"
        record.node_type = row["type"]
      when "host"
        record.host = Node.find_identifier(row["host"])
      when "components"
        record.components = row["components"].split.map do |identifier|
          Node.find_identifier(identifier)
        end
      else
        super
      end
    end

    # override
    def row_to_record(row, record: model_class.new, keys: attrs, **opts)
      record.user = @user if record.new_record? && !@user.nil && !@user.admin?

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
            raise InvalidFieldError, "device type is not fonud by name: #{name}"
          end
          hardware_params[:device_type_id] = device_type.id
        end
        record.hardware = find_or_new_hardware(hardware_params, record.hardware)
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
    rescue InvaildFieldError
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
      return unless params.values_at(:area, :building, :room).any?(&:present?)

      Place.find_or_initialize_by(params)
    end

    private def find_or_new_hardware(params, hardware = nil)
      params = {
        device_type_id: hardware&.device_type_id,
        maker: hardware&.maker || "",
        product_name: hardware&.product_name || "",
        model_number: hardware&.model_number || "",
      }.merge(params)
      return unless params.values.any?(&:present?)

      Hardware.find_or_initialize_by(params)
    end

    private def find_or_new_operating_system(params, operating_system = nil)
      params = {
        os_category_id: operating_system&.os_category_id,
        name: operating_system&.name || "",
      }.merge(params)
      return if params[:os_category_id].blank?

      OperatingSystem.find_or_initialize_by(params)
    end

    private def create_nic(record, params)
      record.nics.create!(params)
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

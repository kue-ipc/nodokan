module NodeParameter
  extend ActiveSupport::Concern

  private def normalize_node_params(node_params)
    delete_unchangable_node_params(node_params)

    number_nics(node_params[:nics_attributes]&.values || [])

    if node_params.key?(:component_ids)
      node_params[:component_ids] = node_params[:component_ids]&.uniq
    end

    if node_params.key?(:place)
      node_params[:place] = find_or_new_place(node_params[:place])
    end

    if node_params.key?(:hardware)
      node_params[:hardware] =
        find_or_new_hardware(node_params[:hardware])
    end

    if node_params.key?(:operating_system)
      node_params[:operating_system] =
        find_or_new_operating_system(node_params[:operating_system])
    end
    node_params
  end

  private def delete_unchangable_node_params(node_params)
    return node_params if current_user.nil? || current_user.admin?

    node_params.delete(:specific)
    node_params.delete(:public)
    node_params.delete(:dns)
    node_params.delete(:user_id)
    node_params[:nics_attributes]&.each_value do |nic_params|
      delete_unchangable_nic_params(nic_params)
    end
    node_params
  end

  private def delete_unchangable_nic_params(nic_params, nic = nil)
    return nic_params if current_user.nil? || current_user.admin?

    nic_params.delete(:locked)

    nic ||= nic_params[:id].presence && Nic.find(nic_params[:id])
    network =
      nic_params[:network_id].presence && Network.find(nic_params[:network_id])

    # ゲストの制限
    if current_user.guest?
      nic_params.delete(:_destroy)
      nic_params[:auth] = network.auth if network
      if ["dynamic", "disabled"].exclude?(nic_params[:ipv4_config])
        nic_params.delete(:ipv4_config)
      end
      if ["dynamic", "disabled"].exclude?(nic_params[:ipv6_config])
        nic_params.delete(:ipv6_config)
      end
    end

    if nic_params[:id].blank?
      # new nic
      if nic_params[:network_id].present? &&
          !Network.find(nic_params[:network_id]).manageable?(current_user)
        # unmanageable
        nic_params[:ipv4_address] = nil
        nic_params[:ipv6_address] = nil
      end
      return
    end

    if nic.locked?
      # delete all except of :id for locked nic
      nic_params.slice!(:id)
      return
    end

    network =
      if nic_params.key?(:network_id)
        nic_params[:network_id].presence &&
          Network.find(nic_params[:network_id])
      else
        nic.network
      end

    return nic_params if network.nil?
    return nic_params if network.manageable?(current_user)

    if network.id == nic.network_id
      if !nic_params.key?(:ipv4_config) ||
          nic_params[:ipv4_config].to_s == nic.ipv4_config
        nic_params.delete(:ipv4_address) # use same ip
      else
        nic_params[:ipv4_address] = nil # reset ip address
      end
      if !nic_params.key?(:ipv6_config) ||
          nic_params[:ipv6_config].to_s == nic.ipv6_config
        nic_params.delete(:ipv6_address) # use same ip
      else
        nic_params[:ipv6_address] = nil # reset ip address
      end
    else
      # reset ip address
      nic_params[:ipv4_address] = nil
      nic_params[:ipv6_address] = nil
    end
    nic_params
  end

  private def number_nics(nics_params)
    nics_params.each_with_index do |nic_params, idx|
      nic_params[:number] = idx + 1
    end
    nics_params
  end

  private def find_or_new_place(place_params, place = nil)
    return if place_params.nil?

    place_params = place_params.to_h.with_indifferent_access

    place_params.merge!(place.attributes) { _2 } if place
    place_params.slice!(:area, :building, :floor, :room)

    return if place_params.values_at(:area, :building, :room).all?(&:blank?)

    place_params[:area] ||= ""
    place_params[:building] ||= ""
    place_params[:floor] = place_params[:floor].to_i
    place_params[:room] ||= ""

    Place.find_or_initialize_by(place_params)
  end

  private def find_or_new_hardware(hardware_params, hardware = nil)
    return if hardware_params.nil?

    hardware_params = hardware_params.to_h.with_indifferent_access

    if hardware_params[:device_type_id].blank? &&
        hardware_params[:device_type].present?
      hardware_params[:device_type_id] = DeviceType
        .where(name: hardware_params[:device_type]).pick(:id) || -1
    end

    hardware_params.merge!(hardware.attributes) { _2 } if hardware
    hardware_params.slice!(:device_type_id, :maker, :product_name,
      :model_number)

    return if hardware_params.values.all?(&:blank?)

    # "" のままでは find_or_initialized_by で引っかからないので nil にする。
    hardware_params[:device_type_id] = hardware_params[:device_type_id].presence
    hardware_params[:maker] ||= ""
    hardware_params[:product_name] ||= ""
    hardware_params[:model_number] ||= ""

    Hardware.find_or_initialize_by(hardware_params)
  end

  private def find_or_new_operating_system(operating_system_params,
    operating_system = nil)
    return if operating_system_params.nil?

    operating_system_params =
      operating_system_params.to_h.with_indifferent_access

    if operating_system_params[:os_category_id].blank? &&
        operating_system_params[:os_category].present?
      operating_system_params[:os_category_id] = OsCategory
        .where(name: operating_system_params[:os_category]).pick(:id) || -1
    end

    if operating_system
      operating_system_params.merge!(operating_system.attributes) { _2 }
    end
    operating_system_params.slice!(:os_category_id, :name)

    return if operating_system_params[:os_category_id].blank?

    operating_system_params[:name] ||= ""

    OperatingSystem.find_or_initialize_by(operating_system_params)
  end
end

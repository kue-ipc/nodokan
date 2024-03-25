module NodesHelper
  NODE_LIST_COLS = [
    {name: :user,         grid: [0, 0, 2, 2, 1, 1]},
    {name: :name,         grid: [4, 3, 3, 3, 3, 2]},
    {name: :hostname,     grid: [3, 3, 2, 2, 2, 1]},
    {name: :place,        grid: [0, 0, 0, 0, 0, 1]},
    {name: :ipv4_address, grid: [5, 4, 3, 2, 2, 2]},
    {name: :ipv6_address, grid: [0, 0, 0, 0, 3, 2]},
    {name: :mac_address,  grid: [0, 0, 0, 0, 0, 2]},
    {name: :confirmation, grid: [0, 2, 2, 2, 1, 1]},
  ].freeze

  NODE_LIST_FILTERS = [
    {name: :specific, type: :boolean},
    {name: :nics_network_id, type: :select,
     collection: -> { current_user.usable_networks.to_a },},
    {name: :user_id, type: :select,
     collection: -> { User.all }, admin_only: true,},
  ]

  NODE_ACTION_LIST_COLS = [
    {name: :user,         grid: [0, 0, 2, 2, 1, 1]},
    {name: :name,         grid: [6, 3, 3, 3, 3, 2]},
    {name: :hostname,     grid: [4, 3, 2, 2, 2, 1]},
    {name: :ipv4_address, grid: [0, 4, 3, 3, 2, 2]},
    {name: :ipv6_address, grid: [0, 0, 0, 0, 3, 3]},
    {name: :mac_address,  grid: [0, 0, 0, 0, 0, 2]},
    {name: :action,       grid: [2, 2, 2, 2, 1, 1]},
  ].freeze

  LIST_COL_CLASSES = {
    user: %w(d-none d-md-block col-md-2 col-lg-2 col-xl-1 col-xxl-1),
    name: %w(col-4 col-sm-3 col-md-3 col-lg-3 col-xl-3 col-xxl-2),
    hostname: %w(col-3 col-sm-3 col-md-2 col-lg-2 col-xl-2 col-xxl-1),
    place: %w(d-none d-xxl-block col-xxl-1),
    ipv4_address: %w(col-5 col-sm-4 col-md-3 col-lg-2 col-xl-2 col-xxl-2),
    ipv6_address: %w(d-none d-xl-block col-xl-3 col-xxl-2),
    mac_address: %w(d-none d-xxl-block col-xxl-2),
    confirmation: %w(d-none d-sm-block col-sm-2 col-md-2 col-lg-2 col-xl-1
      col-xxl-1),
  }.freeze

  def node_flag_attributes
    [:logical, :virtual_machine, :specific, :global, :public, :dns]
  end

  def list_col_classes(name, cols: NODE_LIST_COLS)
    grid_classes(cols.find { |col| col[:name] == name }[:grid])
  end

  def installation_methods(node)
    if node.operating_system
      policy_scope(SecuritySoftware)
        .where(os_category: node.operating_system.os_category)
        .distinct
        .pluck(:installation_method)
    else
      []
    end
  end

  def init_confirmation(node)
    confirmation = node.confirmation || node.build_confirmation
    # check os
    if node.operating_system.nil?
      confirmation.security_software = nil
      confirmation.security_update = nil
      confirmation.security_scan = nil
    elsif confirmation.security_software&.os_category !=
        node.operating_system.os_category

      confirmation.security_software =
        SecuritySoftware.new(os_category: node.operating_system.os_category)
      confirmation.security_update = nil
      confirmation.security_scan = nil
    end
    reset_unknown_confirmation(confirmation)
  end

  private def reset_unknown_confirmation(confirmation)
    Confirmation::NUM_ATTRS.each do |name|
      confirmation.send("#{name}=", nil) if confirmation.send(name) == "unknown"
    end
    if confirmation.security_hardwares&.include?("unknown")
      confirmation.security_hardware = nil
    end
    confirmation
  end

  def node_name_decorated(node)
    node_flag_attributes.select { |attr| node.__send__(attr) }.map { |attr|
      badge_for(attr, scope: "activerecord.attributes.node",
        badge_class: "ms-1")
    }.inject(h(node.name), :+)
  end

  def node_ipv4_address_decorated(node)
    node.nics.map { |nic|
      if nic.ipv4_dynamic?
        tag.span(t_enum(:dynamic, :ipv4_configs), class: "text-success")
      else
        span_value_for(nic.ipv4, blank_alt: "")
      end
    }.inject { |result, item| result + tag.br + item }
  end

  def node_ipv6_address_decorated(node)
    node.nics.map { |nic|
      if nic.ipv6_dynamic?
        tag.span(t_enum(:dynamic, :ipv6_configs), class: "text-success")
      else
        span_value_for(nic.ipv6, blank_alt: "")
      end
    }.inject { |result, item| result + tag.br + item }
  end

  def node_mac_address_decorated(node)
    node.nics.map { |nic| h(nic.mac_address) }
      .inject { |result, item| result + tag.br + item }
  end

  private def node_col_grid_class!(col)
    col[:grid_class] ||= col.fetch(:class, []) + grid_classes(col[:grid])
  end

  def node_list_for(nodes, filters: NODE_LIST_FILTERS,
    write_headers: true, pagination: :both, cols: NODE_LIST_COLS,
    wrapper: {}, action: nil, &block)
    pagination = :both if pagination == true
    tag.div(**wrapper) do
      contents = []
      if filters
        # TODO: 実装すること
      end
      contents << paginate(nodes) if [:both, :above].include?(pagination)
      contents << node_list_table_for(nodes, write_headers: write_headers,
        cols: cols, action: action, &block)
      contents << paginate(nodes) if [:both, :below].include?(pagination)
      contents << tag.p(page_entries_info(nodes)) if pagination
      contents.inject(:+)
    end
  end

  def node_list_table_for(nodes, write_headers: true, cols: NODE_LIST_COLS,
    action: nil)
    tag.div(class: "mb-2") do
      rows = []
      rows << node_list_headers_for(cols: cols) if write_headers
      nodes.each do |node|
        rows <<
          if block_given?
            capture { yield node }
          else
            node_list_col_for(node, cols: cols, action: action)
          end
      end
      rows.inject(:+)
    end
  end

  def node_list_headers_for(cols: NODE_LIST_COLS)
    tag.div(class: "row pb-1 mb-1 fw-bold border-bottom") do
      cols.map { |col|
        name = col[:name]
        opts = {class: node_col_grid_class!(col)}
        case name
        when :action
          tag.div(t("messages.action"), **opts)
        when :ipv4_address, :ipv6_address, :mac_address
          tag.div(Nic.human_attribute_name(name), **opts)
        else
          tag.div(Node.human_attribute_name(name), **opts)
        end
      }.inject(:+)
    end
  end

  def node_list_col_for(node, cols: NODE_LIST_COLS, action: nil)
    tag.div(class: "row py-1 border-bottom") do
      cols.map { |col|
        name = col[:name]
        opts = {class: node_col_grid_class!(col)}
        case name
        when :action
          if block_given?
            tag.div(**opts) { yield node }
          else
            tag.div(action&.call(node), **opts)
          end
        when :user
          tag.div(node.user&.username, **opts)
        when :name
          tag.div(node_name_decorated(node), **opts)
        when :ipv4_address
          tag.div(node_ipv4_address_decorated(node), **opts)
        when :ipv6_address
          tag.div(node_ipv6_address_decorated(node), **opts)
        when :mac_address
          tag.div(node_mac_address_decorated(node), **opts)
        else
          tag.div(node.__send__(name), **opts)
        end
      }.inject(:+)
    end
  end
end

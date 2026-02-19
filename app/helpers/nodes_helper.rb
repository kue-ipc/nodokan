module NodesHelper
  NODE_LIST_COLS = [
    {name: :user,         grid: [0, 0, 2, 2, 1, 1]},
    {name: :name,         grid: [4, 3, 3, 3, 3, 2], sort: :name},
    {name: :hostname,     grid: [3, 3, 2, 2, 2, 1], sort: :hostname},
    {name: :place,        grid: [0, 0, 0, 0, 0, 1]},
    {name: :ipv4_address, grid: [5, 4, 3, 2, 2, 2], sort: :nics_ipv4},
    {name: :ipv6_address, grid: [0, 0, 0, 0, 3, 2], sort: :nics_ipv6},
    {name: :mac_address,  grid: [0, 0, 0, 0, 0, 2], sort: :nics_mac_address},
    {name: :confirmation, grid: [0, 2, 2, 2, 1, 1]},
  ].freeze

  # when confirmation feature is disabled
  NODE_WITHOUT_CONFIRMATION_LIST_COLS = [
    {name: :user,         grid: [0, 0, 2, 2, 1, 1]},
    {name: :name,         grid: [4, 4, 3, 3, 3, 2], sort: :name},
    {name: :hostname,     grid: [3, 3, 3, 3, 2, 1], sort: :hostname},
    {name: :place,        grid: [0, 0, 0, 0, 0, 1]},
    {name: :ipv4_address, grid: [5, 5, 4, 4, 2, 2], sort: :nics_ipv4},
    {name: :ipv6_address, grid: [0, 0, 0, 0, 4, 3], sort: :nics_ipv6},
    {name: :mac_address,  grid: [0, 0, 0, 0, 0, 2], sort: :nics_mac_address},
  ].freeze

  NODE_ACTION_LIST_COLS = [
    {name: :user,         grid: [0, 0, 2, 2, 1, 1]},
    {name: :name,         grid: [6, 3, 3, 3, 3, 2]},
    {name: :hostname,     grid: [4, 3, 2, 2, 2, 1]},
    {name: :ipv4_address, grid: [0, 4, 3, 3, 2, 2]},
    {name: :ipv6_address, grid: [0, 0, 0, 0, 3, 3]},
    {name: :mac_address,  grid: [0, 0, 0, 0, 0, 2]},
    {name: :action,       grid: [2, 2, 2, 2, 1, 1]},
  ].freeze

  NODE_DOUBLE_ACTION_LIST_COLS = [
    {name: :name,         grid: [8, 4, 4, 4, 3, 2]},
    {name: :hostname,     grid: [0, 3, 2, 2, 2, 1]},
    {name: :ipv4_address, grid: [0, 0, 4, 4, 2, 2]},
    {name: :ipv6_address, grid: [0, 0, 0, 0, 3, 3]},
    {name: :mac_address,  grid: [0, 0, 0, 0, 0, 2]},
    {name: :action,       grid: [4, 3, 2, 2, 2, 2]},
  ].freeze

  LIST_COL_CLASSES = {
    user:         %w[d-none d-md-block col-md-2 col-lg-2 col-xl-1 col-xxl-1],
    name:         %w[col-4 col-sm-3 col-md-3 col-lg-3 col-xl-3 col-xxl-2],
    hostname:     %w[col-3 col-sm-3 col-md-2 col-lg-2 col-xl-2 col-xxl-1],
    place:        %w[d-none d-xxl-block col-xxl-1],
    ipv4_address: %w[col-5 col-sm-4 col-md-3 col-lg-2 col-xl-2 col-xxl-2],
    ipv6_address: %w[d-none d-xl-block col-xl-3 col-xxl-2],
    mac_address:  %w[d-none d-xxl-block col-xxl-2],
    confirmation: %w[d-none d-sm-block col-sm-2 col-md-2 col-lg-2 col-xl-1 col-xxl-1],
  }.freeze

  def node_list_cols
    if Settings.feature.confirmation
      NODE_LIST_COLS
    else
      NODE_WITHOUT_CONFIRMATION_LIST_COLS
    end
  end

  def node_type_names
    names = %i[normal mobile]
    names << :virtual if Settings.feature.virtual_node
    names << :logical if Settings.feature.logical_node
    names
  end

  def node_flag_names
    attributes = %i[disabled permanent public dns]
    attributes << :specific if Settings.feature.specific_node
    attributes
  end

  def list_col_classes(name, cols: node_list_cols)
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
    elsif confirmation.security_software&.os_category != node.operating_system.os_category
      confirmation.security_software = SecuritySoftware.new(os_category: node.operating_system.os_category)
      confirmation.security_update = nil
      confirmation.security_scan = nil
    end
    reset_unknown_confirmation(confirmation)
  end

  private def reset_unknown_confirmation(confirmation)
    Confirmation::NUM_ATTRS.each do |name|
      confirmation.send("#{name}=", nil) if confirmation.send(name) == "unknown"
    end
    confirmation.security_hardware = nil if confirmation.security_hardwares&.include?("unknown")
    confirmation
  end

  def node_name_decorated(node)
    type_badge = badge_for(node, :node_type, hidden: node.normal?)
    node_flag_names.map { |name| badge_for(node, name) }.inject(h(node.name) + type_badge, :+)
  end

  def node_ipv4_address_decorated(node)
    node.nics.map do |nic|
      if nic.ipv4_dynamic?
        tag.span(t_enum(:dynamic, :ipv4_config), class: "text-success-emphasis")
      else
        span_value_for(nic.ipv4, blank_alt: "")
      end
    end.inject { |result, item| result + tag.br + item }
  end

  def node_ipv6_address_decorated(node)
    node.nics.map do |nic|
      if nic.ipv6_dynamic?
        tag.span(t_enum(:dynamic, :ipv6_config), class: "text-success-emphasis")
      else
        span_value_for(nic.ipv6, blank_alt: "")
      end
    end.inject { |result, item| result + tag.br + item }
  end

  def node_confirmation_decorated(node)
    case node.solid_confirmation.status
    when :unconfirmed
      tag.i(class: "fas fa-times-circle text-danger-emphasis") +
        tag.span(t("messages.unconfirmed"), class: "text-danger-emphasis")
    when :expired
      tag.i(class: "fas fa-times-circle text-danger-emphasis") +
        tag.span(t("messages.expired"), class: "text-danger-emphasis")
    when :unapproved
      tag.i(class: "fas fa-exclamation-triangle text-warning-emphasis") +
        tag.span(t("messages.unapproved"), class: "text-warning-emphasis")
    when :expire_soon
      tag.i(class: "fas fa-exclamation-triangle text-warning-emphasis") +
        tag.span(t("messages.expire_soon"), class: "text-warning-emphasis")
    when :approved
      tag.i(class: "fas fa-check text-success-emphasis") +
        tag.span(t("messages.approved"), class: "text-success-emphasis")
    end
  end

  def node_mac_address_decorated(node)
    node.nics.map { |nic| h(nic.mac_address) }
      .inject { |result, item| result + tag.br + item }
  end

  def node_list_for(nodes,
    write_headers: true, pagination: :both, cols: node_list_cols,
    wrapper: {}, action: nil, &block)
    pagination = :both if pagination == true
    tag.div(**wrapper) do
      contents = []
      contents << paginate(nodes) if [:both, :above].include?(pagination)
      contents << node_list_table_for(nodes, write_headers:, cols:, action:,
        &block)
      contents << paginate(nodes) if [:both, :below].include?(pagination)
      contents << tag.p(page_entries_info(nodes)) if pagination
      contents.inject(:+)
    end
  end

  def node_list_table_for(nodes, write_headers: true, cols: node_list_cols,
    action: nil)
    tag.div(class: "mb-2") do
      rows = []
      rows << node_list_headers_for(cols:) if write_headers
      nodes.each do |node|
        rows <<
          if block_given?
            capture { yield node }
          else
            node_list_col_for(node, cols:, action:)
          end
      end
      rows.inject(:+)
    end
  end

  def node_list_headers_for(cols: node_list_cols)
    tag.div(class: "row py-1 border-bottom fw-bold") do
      cols.map do |col|
        name = col[:name]
        opts = {class: col_grid_class(col)}
        content =
          case name
          when :action
            t("messages.action")
          when :ipv4_address, :ipv6_address, :mac_address
            h(Nic.human_attribute_name(name))
          else
            h(Node.human_attribute_name(name))
          end
        content += h(" ") + sort_link(col[:sort]) if col[:sort]
        tag.div(content, **opts)
      end.inject(:+)
    end
  end

  def node_list_col_for(node, cols: node_list_cols, link: nil, action: nil)
    content = cols.map do |col|
      name = col[:name]
      opts = {class: col_grid_class(col)}
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
      when :place
        tag.div(node.place&.short_name, **opts)
      when :confirmation
        tag.div(node_confirmation_decorated(node), **opts)
      when :ipv4_address
        tag.div(node_ipv4_address_decorated(node), **opts)
      when :ipv6_address
        tag.div(node_ipv6_address_decorated(node), **opts)
      when :mac_address
        tag.div(node_mac_address_decorated(node), **opts)
      else
        tag.div(node.__send__(name), **opts)
      end
    end.inject(:+)

    if link
      link_to(content, link, class: "row py-1 border-bottom",
        data: {turbo: false})
    else
      tag.div(content, class: "row py-1 border-bottom")
    end
  end
end

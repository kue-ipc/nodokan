module HostsHelper
  # rubocop: disable Layout
  NODE_HOSTS_LIST_COL_CLASSES = {
    action:       %w(col-3 col-sm-2 col-md-2 col-lg-2 col-xl-1 col-xxl-1),
    name:         %w(col-6 col-sm-3 col-md-3 col-lg-3 col-xl-3 col-xxl-2),
    hostname:     %w(col-3 col-sm-3 col-md-2 col-lg-2 col-xl-2 col-xxl-1),
    ipv4_address: %w(d-none d-sm-block col-sm-4 col-md-3 col-lg-2 col-xl-2 col-xxl-2),
    ipv6_address: %w(d-none d-xl-block                col-xl-3 col-xxl-2),
  }.freeze
  # rubocop: enable Layout

  def node_flag_attributes
    [:logical, :virtual_machine, :specific, :global, :public, :dns]
  end

  def node_hosts_list_col_classes(name)
    NODE_HOSTS_LIST_COL_CLASSES[name]
  end
end

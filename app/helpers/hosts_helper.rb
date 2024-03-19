module HostsHelper
  # rubocop: disable Layout
  NODE_HOSTS_LIST_COL_CLASSES = {
    action:       %w(            col-2 col-md-1 col-xl-1),
    name:         %w(            col-6 col-md-5 col-xl-3),
    hostname:     %w(            col-4 col-md-3 col-xl-2),
    ipv4_address: %w(d-none d-md-block col-md-3 col-xl-2),
    ipv6_address: %w(d-none d-xl-block          col-xl-4),
  }.freeze
  # rubocop: enable Layout

  def node_flag_attributes
    [:logical, :virtual_machine, :specific, :global, :public, :dns]
  end

  def node_hosts_list_col_classes(name)
    NODE_HOSTS_LIST_COL_CLASSES[name]
  end
end

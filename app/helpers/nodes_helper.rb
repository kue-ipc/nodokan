module NodesHelper
  # rubocop: disable Layout
  LIST_COL_CLASSES = {
    user:         %w(d-none d-md-block          col-md-2 col-lg-2 col-xl-1 col-xxl-1),
    name:         %w(            col-4 col-sm-3 col-md-3 col-lg-3 col-xl-3 col-xxl-2),
    hostname:     %w(            col-3 col-sm-3 col-md-2 col-lg-2 col-xl-2 col-xxl-1),
    place:        %w(d-none d-xxl-block                                    col-xxl-1),
    ipv4_address: %w(            col-5 col-sm-4 col-md-3 col-lg-2 col-xl-2 col-xxl-2),
    ipv6_address: %w(d-none d-xl-block                            col-xl-3 col-xxl-2),
    mac_address:  %w(d-none d-xxl-block                                    col-xxl-2),
    confirmation: %w(d-none d-sm-block col-sm-2 col-md-2 col-lg-2 col-xl-1 col-xxl-1),
  }.freeze
  # rubocop: enable Layout

  def list_col_classes(name)
    LIST_COL_CLASSES[name]
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
end

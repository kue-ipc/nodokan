class KeaDhcp6OptionJob < ApplicationJob
  queue_as :default

  def perform(options)
    Kea::Dhcp6Option.transaction do
      Kea::Dhcp6Subnet.dhcp6_audit

      default_server = Kea::Dhcp6Server.default
      global_scope = Kea::DhcpOptionScope.global
      option_params = {
        space: "dhcp6",
        dhcp_option_scope: global_scope,
        dhcp6_servers: [default_server],
      }

      current_options =
        Kea::Dhcp6Option.where(dhcp_option_scope: global_scope).index_by(&:name)

      options.compact_blank
        .transform_keys { |key| Kea::Dhcp6Option.normalize_name(key) }
        .each do |key, value|
        if (existing_option = current_options.delete(key))
          existing_option.update!(data: value, **option_params)
        else
          Kea::Dhcp6Option.create!(name: key, data: value, **option_params)
        end
      end
      current_options.each_value(&:destroy!)
    end
  end
end

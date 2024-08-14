class KeaDhcp4OptionJob < ApplicationJob
  queue_as :default

  def perform(options)
    Kea::Dhcp4Option.transaction do
      Kea::Dhcp4Subnet.dhcp4_audit

      default_server = Kea::Dhcp4Server.default
      global_scope = Kea::DhcpOptionScope.global
      option_params = {
        space: "dhcp4",
        dhcp_option_scope: global_scope,
        dhcp4_servers: [default_server],
      }

      current_options =
        Kea::Dhcp4Option.where(dhcp_option_scope: global_scope).index_by(&:name)

      options.compact_blank
        .transform_keys { |key| Kea::Dhcp4Option.normalize_name(key) }
        .each do |key, value|
        if (existing_option = current_options.delete(key))
          existing_option.update!(data: value, **option_params)
        else
          Kea::Dhcp4Option.create!(name: key, data: value, **option_params)
        end
      end
      current_options.each_value(&:destroy!)
    end
  end
end

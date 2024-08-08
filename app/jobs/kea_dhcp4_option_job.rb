class KeaDhcp4OptionJob < ApplicationJob
  queue_as :default

  def perform(options)
    Kea::Dhcp4Option.transaction do
      Kea::Dhcp4Subnet.dhcp4_audit

      global_scope = Kea::DhcpOptionScope.global
      current_options =
        Kea::Dhcp4Option.where(scope: global_scope).index_by(&:name)
      options.compact_blank
        .transform_keys { |key| Kea::Dhcp4Option.normalize_name(key) }
        .each do |key, value|
        if (existing_option = current_options.delete(key))
          existing_option.update!(data: value)
        else
          Kea::Dhcp4Option.create!(name: key, data: value, scope: global_scope,
            space: "dhcp4")
        end
      end
      current_options.each_value(&:destroy!)
    end
  end
end

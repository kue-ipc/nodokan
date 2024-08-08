class KeaDhcp6OptionJob < ApplicationJob
  queue_as :default

  def perform(options)
    Kea::Dhcp6Option.transaction do
      Kea::Dhcp6Subnet.dhcp6_audit

      global_scope = Kea::DhcpOptionScope.global
      current_options =
        Kea::Dhcp6Option.where(scope: global_scope).index_by(&:name)
      options.compact_blank
        .transform_keys { |key| Kea::Dhcp6Option.normalize_name(key) }
        .each do |key, value|
        if (existing_option = current_options.delete(key))
          existing_option.update!(data: value)
        else
          Kea::Dhcp6Option.create!(name: key, data: value, scope: global_scope,
            space: "dhcp6")
        end
      end
      current_options.each_value(&:destroy!)
    end
  end
end

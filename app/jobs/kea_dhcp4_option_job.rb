class KeaDhcp4OptionJob < ApplicationJob
  queue_as :default

  def perform(options)
    Kea::Dhcp4Option.transaction do
      global_scope = Kea::DhcpOptionScope.global
      current_options = Kea::Dhcp4Option.where(dhcp_option_scope: global_scope)
        .index_by { |option| option.name.intern }

      Kea::Dhcp4Subnet.dhcp4_audit

      options.each do |key, value|
        cur = current_options.delete(key)
        if cur
          cur.update!(data: value)
        else
          Kea::Dhcp4Option.create!(
            name: key,
            data: value,
            dhcp_option_scope: global_scope)
        end
      end

      # 残りのオプションは削除
      current_options.each_value(&:destroy!)
    end
  end
end

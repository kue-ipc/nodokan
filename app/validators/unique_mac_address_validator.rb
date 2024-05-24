class UniqueMacAddressValidator < ActiveModel::Validator
  def validate(record)
    # TODO: メッセージは異なる方がよいと思われる。
    return if record.mac_address_data.blank?

    if Nic.where.not(node: record.node)
        .exists?(mac_address_data: record.mac_address_data)
      record.errors.add(:mac_address_data,
        options[:message] || I18n.t("errors.messages.taken"))
    end

    return if record.network_id.blank?

    same_mac_address_nics = record.node.nics.select { |nic|
      nic != record &&
        nic.mac_address_data == record.mac_address_data &&
        nic.network_id.present?
    }

    if same_mac_address_nics.map(&:network_id).include?(record.network_id)
      record.errors.add(:mac_address_data,
        options[:message] || I18n.t("errors.messages.taken"))
    end
    if record.auth && same_mac_address_nics.any?(&:auth)
      record.errors.add(:mac_address_data,
        options[:message] || I18n.t("errors.messages.taken"))
    end
  end
end

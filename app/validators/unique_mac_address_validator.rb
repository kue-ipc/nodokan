class UniqueMacAddressValidator < ActiveModel::Validator
  def validate(record)
    return if record.mac_address_data.blank?


    if Nic.where.not(node: record.node)
        .exists?(mac_address_data: record.mac_address_data)
      record.errors.add(:mac_address_data,
        options[:message] || I18n.t("errors.messages.taken"))
      return
    end

    return if record.network_id.blank?

    if record.node.nics.reject { |nic| nic == record }
        .select { |nic| nic.mac_address_data == record.mac_address_data }
        .map(&:network_id).include?(record.network_id)
      record.errors.add(:mac_address_data,
        options[:message] || I18n.t("errors.messages.taken"))
      nil
    end
  end
end

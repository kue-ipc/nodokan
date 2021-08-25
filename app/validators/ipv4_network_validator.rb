# IPv4 Network Address Validator
class Ipv4NetworkValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.network?
      record.errors.add(attribute, options[:message] || I18n.t(:not_ipv4_network, scope: [:errors, :messages]))
    end

    if value.u32 >> 24 == 0
      record.errors.add(attribute, options[:message] || I18n.t(:ipv4_unspecified, scope: [:errors, :messages]))
    end

    if value.loopback?
      record.errors.add(attribute, options[:message] || I18n.t(:ipv4_loopback, scope: [:errors, :messages]))
    end

    if value.link_local?
      record.errors.add(attribute, options[:message] || I18n.t(:ipv4_link_local, scope: [:errors, :messages]))
    end

    if value.multicast?
      record.errors.add(attribute, options[:message] || I18n.t(:ipv4_multicast, scope: [:errors, :messages]))
    end
  end
end

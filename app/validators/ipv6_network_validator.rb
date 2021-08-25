# IPv6 Network Address Validator
class Ipv6NetworkValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.network?
      record.errors.add(attribute, options[:message] || I18n.t(:not_ipv6_network, scope: [:errors, :messages]))
    end

    if value.unspecified?
      record.errors.add(attribute, options[:message] || I18n.t(:ipv6_unspecified, scope: [:errors, :messages]))
    end

    if value.loopback?
      record.errors.add(attribute, options[:message] || I18n.t(:ipv6_loopback, scope: [:errors, :messages]))
    end

    if value.link_local?
      record.errors.add(attribute, options[:message] || I18n.t(:ipv6_link_local, scope: [:errors, :messages]))
    end

    if value.to_u128 >> 120 == 0xff
      record.errors.add(attribute, options[:message] || I18n.t(:ipv6_multicast, scope: [:errors, :messages]))
    end

    if value.mapped?
      record.errors.add(attribute, options[:message] || I18n.t(:ipv6_mapped, scope: [:errors, :messages]))
    end
  end
end

# IPv6 Network Address Validator
class Ipv6NetworkValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, options[:message] || I18n.t('errors.messages.not_ipv6_network')) unless value.network?

    record.errors.add(attribute, options[:message] || I18n.t('errors.messages.ipv6_unspecified')) if value.unspecified?

    record.errors.add(attribute, options[:message] || I18n.t('errors.messages.ipv6_loopback')) if value.loopback?

    record.errors.add(attribute, options[:message] || I18n.t('errors.messages.ipv6_link_local')) if value.link_local?

    if value.to_u128 >> 120 == 0xff
      record.errors.add(attribute, options[:message] || I18n.t('errors.messages.ipv6_multicast'))
    end

    record.errors.add(attribute, options[:message] || I18n.t('errors.messages.ipv6_mapped')) if value.mapped?
  end
end

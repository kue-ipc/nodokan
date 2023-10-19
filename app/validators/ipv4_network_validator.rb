# IPv4 Network Address Validator
class Ipv4NetworkValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, options[:message] || I18n.t('errors.messages.not_ipv4_network')) unless value.network?

    if value.u32 >> 24 == 0
      record.errors.add(attribute, options[:message] || I18n.t('errors.messages.ipv4_unspecified'))
    end

    record.errors.add(attribute, options[:message] || I18n.t('errors.messages.ipv4_loopback')) if value.loopback?

    record.errors.add(attribute, options[:message] || I18n.t('errors.messages.ipv4_link_local')) if value.link_local?

    record.errors.add(attribute, options[:message] || I18n.t('errors.messages.ipv4_multicast')) if value.multicast?
  end
end

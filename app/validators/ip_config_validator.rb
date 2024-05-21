# IP Config Validator
class IpConfigValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    configs = record.network&.__send__(attribute.to_s.pluralize) || ["disabled"]
    return if configs.include?(value)

    record.errors.add(attribute, :invalid_config)
  end
end

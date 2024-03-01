# IP Config Validator
class IpConfigValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if record.network&.send(attribute.to_s.pluralize)&.include?(value)

    record.errors.add(attribute, :invalid_config)
  end
end

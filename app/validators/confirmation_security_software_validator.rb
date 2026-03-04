# Confirmation security_software Validator
class ConfirmationSecuritySoftwareValidator < ActiveModel::Validator
  def validate(record)
    return if record.security_software.nil?

    if record.operating_system.nil?
      record.errors.add(:security_software, options[:message] || I18n.t("errors.messages.no_os_for_security_software"))
    elsif record.security_software.os_category_id != record.operating_system.os_category_id
      record.errors.add(:security_software, options[:message] || I18n.t("errors.messages.unusable_security_software"))
    end
  end
end

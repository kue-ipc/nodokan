module ConfirmationParameter
  extend ActiveSupport::Concern

  private def normalize_confirmation_params(confirmation_params)
    if confirmation_params.key?(:security_hardwares)
      confirmation_params[:security_hardware] =
        Confirmation.security_hardware_list_to_bitwise(confirmation_params[:security_hardwares])
      confirmation_params.delete(:security_hardwares)
    end

    if confirmation_params.key?(:security_software)
      confirmation_params[:security_software] = find_or_new_security_software(confirmation_params[:security_software])
    end

    confirmation_params
  end

  def find_or_new_security_software(security_software_params, security_software = nil)
    return if security_software_params.nil?

    find_params = security_software_params.slice(:os_category_id, :installation_method, :name)

    if security_software
      find_params[:os_category_id] ||= security_software.os_category_id
      find_params[:installation_method] ||= security_software.installation_method
      find_params[:name] ||= security_software.name
    else
      find_params[:name] ||= ""
    end

    return if [:os_category_id, :installation_method, :name].any? { |key| find_params[key].nil? }

    SecuritySoftware.find_or_initialize_by(find_params)
  end
end

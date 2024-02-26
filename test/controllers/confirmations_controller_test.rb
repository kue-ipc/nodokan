require "test_helper"

class ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def confirmation_to_params(confirmation)
    {
      existence: confirmation.existence,
      content: confirmation.content,
      os_update: confirmation.os_update,
      app_update: confirmation.app_update,
      software: confirmation.software,
      security_hardwares: confirmation.security_hardwares,
      security_update: confirmation.security_update,
      security_scan: confirmation.security_scan,
      security_software: {
        os_category: confirmation.security_software&.os_category,
        installation_method: @confirmation.security_software&.installation_method,
        name: @confirmation.security_software&.name,
      },
    }
  end

  setup do
    @confirmation = confirmations(:desktop)
  end
end

require "ipaddr"
require "json"

require "import_export/processors/application_processor"

module ImportExport
  module Processors
    class ConfirmationsProcessor < ApplicationProcessor
      class_name "Confirmation"

      params_permit(
        :node,
        :existence,
        :content,
        :os_update,
        :app_update,
        :software,
        :security_update,
        :security_scan,
        security_hardwares: [],
        security_software: [:installation_method, :name])

      converter :node, set: ->(record, value) {
        record.node = value && Node.find_identifier(value)
      }
    end
  end
end

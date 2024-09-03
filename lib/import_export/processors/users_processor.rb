require "import_export/processors/application_processor"

module ImportExport
  module Processors
    class UsersProcessor < ApplicationProcessor
      class_name "User"

      params_permit(
        :username, :email, :fullname, :flag, :role, :limit,
        (:auth_network if Settings.feature.user_auth_network), {networks: []})

      converter :auth_network, set: ->(record, value) {
        record.auth_network = Network.find_identifier(value)
      }

      converter :networks, get: ->(record) {
        manage_ids = record.manage_network_ids
        record.use_networks.map do |network|
          if manage_ids.include?(network.id)
            "*#{network.identifier}"
          else
            network.identifier
          end
        end
      }, set: ->(record, value) {
        if record.new_record?
          record.assignments = value.map do |str|
            manage = str.start_with?("*")
            str = str.delete_prefix("*") if manage
            network = Network.find_identifier(str)
            Assignment.new(network:, auth: false, use: true, manage:)
          end
        else
          use_ids = record.use_network_ids
          value.each do |str|
            manage = str.start_with?("*")
            str = str.delete_prefix("*") if manage
            network = Network.find_identifier(str)
            record.add_use_network(network, manage:)
            use_ids.delete(network.id)
          end
          use_ids.each { |network_id| record.remove_use_network_id(network_id) }
        end
      }
    end
  end
end

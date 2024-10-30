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
        record.use_assignments.includes(:network)
          .order(default: :desc, id: :asc)
          .select(&:network)
          .map do |assignment|
            prefix = assignment.manage? ? "*" : ""
            prefix + assignment.network.identifier
        end
      }, set: ->(record, value) {
        if record.new_record?
          record.assignments = value.each_with_index.map do |str, idx|
            default = idx.zero?
            manage = str.start_with?("*")
            str = str.delete_prefix("*") if manage
            network = Network.find_identifier(str)
            Assignment.new(network:, auth: false, use: true, default:, manage:)
          end
        else
          use_ids = record.use_network_ids
          value.each_with_index do |str, idx|
            default = idx.zero?
            manage = str.start_with?("*")
            str = str.delete_prefix("*") if manage
            network = Network.find_identifier(str)
            record.add_use_network(network, {default:, manage:})
            use_ids.delete(network.id)
          end
          use_ids.each { |network_id| record.remove_use_network_id(network_id) }
        end
      }
    end
  end
end

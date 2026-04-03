class UsersProcessor < ApplicationProcessor
  model_name "User"

  keys [
    :username, :email, :fullname, :flag, :role, :limit,
    (:auth_network if Settings.feature.user_auth_network),
    networks: [],
  ].compact

  converter :auth_network, set: ->(record, value) {
    record.auth_network = Network.find_by_identifier!(value)
  }

  converter :networks,
    get: ->(record) {
      record.use_assignments.includes(:network).map { |assignment| serialize_use_assignment(assignment) }
    },
    set: ->(record, value) {
      if record.new_record?
        value&.each do |str|
          assignment = deserialize_use_assignment(str)
          record.assignments.build({
            network_id: assignment.network_id,
            use: true,
            default: assignment.default,
            manage: assignment.manage,
          })
        end
      else
        use_ids = record.use_network_ids
        value&.each do |str|
          assignment = deserialize_use_assignment(str)
          record.add_use_network(assignment.network, {default: assignment.default, manage: assignment.manage})
          use_ids.delete(assignment.network.id)
        end
        use_ids.each { |network_id| record.remove_use_network_id(network_id) }
      end
    }

  def serialize_use_assignment(assignment)
    "#{assignment.use_flag}#{assignment.network.identifier}"
  end

  def deserialize_use_assignment(str)
    m = /\A([+^]*)(.*)\z/.match(str.strip)
    network = Network.find_by_identifier!(m[2])
    assignment = Assignment.new(network:, use: true)
    assignment.use_flag = m[1]
    assignment
  end

end

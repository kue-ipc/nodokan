require "import_export/base_csv"

module ImportExport
  class UserCsv < BaseCsv
    def model_class
      User
    end

    def attrs
      %w(
        username
        email
        fullname
        role
        flag
        limit
        auth_network
        use_networks
        manage_networks
      )
    end

    def row_to_record(row, user)
      user.assign_attributes(
        username: row["username"],
        email: row["email"],
        fullname: row["fullname"],
        role: row["role"],
        flag: row["flag"],
        auth_network: Network.find_identifier(row["auth_network"]))
      user.clear_use_networks
      row["networks"]&.split&.each do |nw|
        user.add_use_network(Network.find_identifier(nw))
      end
      user
    end
  end
end

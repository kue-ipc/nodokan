class AddOptionsToNetworks < ActiveRecord::Migration[7.1]
  def change
    add_column :networks, :domain, :string
    add_column :networks, :domain_search_data, :json
    add_column :networks, :ipv4_dns_servers_data, :json
    add_column :networks, :ipv6_dns_servers_data, :json
  end
end

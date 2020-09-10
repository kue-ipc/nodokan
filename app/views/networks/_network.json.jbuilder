json.extract! network, :id, :name, :vlan, :dhcp, :auth, :closed, :ip_address, :ip_prefix, :ip_gateway, :ip6_address, :ip6_prefix, :ip6_gateway, :created_at, :updated_at
json.url network_url(network, format: :json)

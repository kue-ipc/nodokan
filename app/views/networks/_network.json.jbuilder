json.extract! network, :id, :name, :vlan, :auth,
  :ipv4_network_address, :ipv4_netmask, :ipv4_prefix_length, :ipv4_gateway_address,
  :ipv6_network_address, :ipv6_prefix_length, :ipv6_gateway_address,
  :note, :created_at, :updated_at
json.ipv4_pools do
  json.array! network.ipv4_pools, partial: "ipv4_pools/ipv4_pool",
    as: :ipv4_pool
end
json.ipv6_pools do
  json.array! network.ipv6_pools, partial: "ipv6_pools/ipv6_pool",
    as: :ipv6_pool
end
json.url network_url(network, format: :json)

json.extract! network, :id, :name,
  :vlan, :auth,
  :ip_network_address, :ip_netmask, :ip_prefixlen, :ip_gateway_address,
  :ip6_network_address, :ip6_prefixlen, :ip6_gateway_address,
  :note, :created_at, :updated_at
json.url network_url(network, format: :json)
json.ip_pools do
  json.array! network.ip_pools, partial: 'ip_pools/ip_pool', as: :ip_pool
end
json.ip6_pools do
  json.array! network.ip6_pools, partial: 'ip6_pools/ip6_pool', as: :ip_pool
end

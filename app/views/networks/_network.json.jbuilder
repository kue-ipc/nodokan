json.extract! network, :id, :name,
  :vlan, :auth,
  :ip_address, :ip_mask, :ip_gateway,
  :ip6_address, :ip6_prefix, :ip6_gateway,
  :available_ip_configs, :available_ip6_configs,
  :note, :created_at, :updated_at
json.url network_url(network, format: :json)
json.ip_pools do
  json.array! network.ip_pools, partial: 'ip_pools/ip_pool', as: :ip_pool
end
json.ip6_pools do
  json.array! network.ip6_pools, partial: 'ip6_pools/ip6_pool', as: :ip_pool
end

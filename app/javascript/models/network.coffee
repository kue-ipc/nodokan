import ApplicationRecord from './application_record'
import Ipv4Pool from './ipv4_pool'
import Ipv6Pool from './ipv6_pool'
import ipaddr from 'ipaddr.js'

export default class Network extends ApplicationRecord
  @networks = new Map

  @fetch: (id) ->
    if typeof id != 'string'
      id = String(id)

    unless /^\d+$/.test(id)
      throw new TypeError("#{id} is not positive integer nmuber string")

    if @networks.has(id)
      return @networks.get(id)

    url = "/networks/#{id}.json"

    response = await fetch(url)

    if response.status == 404
      console.log "network #{id} is not found for current user"
      return null

    data = await response.json()

    network = new Network(data)
    @networks.set(id, network)
    network

  constructor: ({@name, @vlan, @auth, @note,
      ipv4_network_address, ipv4_prefix_length, ipv4_gateway_address,
      ipv6_network_address, ipv6_prefix_length, ipv6_gateway_address,
      ipv4_pools, ipv6_pools, props...}) ->
    super(props)
    @ipv4_network = if ipv4_network_address
      ipaddr.parse(ipv4_network_address)
    @ipv4_gateway = if ipv4_gateway_address
      ipaddr.parse(ipv4_gateway_address)
    @ipv6_network = if ipv6_network_address
      ipaddr.parse(ipv6_network_address)
    @ipv6_gateway = if ipv6_gateway_address
      ipaddr.parse(ipv6_gateway_address)
    @ipv4_pools = (new Ipv4Pool(ipv4_pool) for ipv4_pool in ipv4_pools)
    @ipv6_pools = (new Ipv6Pool(ipv6_pool) for ipv6_pool in ipv6_pools)

    @ipv4 = {
      network: @ipv4_network
      gateway: @ipv4_gateway
      pools: @ipv4_pools
    }

    @ipv6 = {
      network: @ipv6_network
      gateway: @ipv6_gateway
      pools: @ipv6_pools
    }

    @ipv4_config_list = @availableIpConfig('ipv4')
    @ipv6_config_list = @availableIpConfig('ipv6')

  # disabledは常に設定可能
  availableIpConfig: (ip_version) ->
    configs = new Set(pool.ip_config() for pool in @[ip_version].pools)
    unless configs.has('dynamic') || configs.has('reserved')
      configs.add('link_local')
    # configs.add('manual')
    configs.add('disabled')
    [...configs]

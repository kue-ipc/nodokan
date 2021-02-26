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
    data = await response.json()

    network = new Network(data)
    @networks.set(id, network)
    network

  constructor: ({@name, @vlan, @auth, @note,
      ipv4_network_address, ipv4_prefixlen, ipv4_gateway_address,
      ipv6_network_address, ipv6_prefixlen, ipv6_gateway_address,
      ipv4_pools, ipv6_pools, props...}) ->
    super(props)
    @ipv4_network = if ipv4_network_address then ipaddr.parse(ipv4_network_address)
    @ipv4_gateway = if ipv4_gateway_address then ipaddr.parse(ipv4_gateway_address)
    @ipv6_network = if ipv6_network_address then ipaddr.parse(ipv6_network_address)
    @ipv6_gateway = if ipv6_gateway_address then ipaddr.parse(ipv6_gateway_address)

    @ipv4_pools = ipv4_pools.map (ipv4_pool) -> new Ipv4Pool(ipv4_pool)
    @ipv6_pools = ipv6_pools.map (ipv6_pool) -> new Ipv6Pool(ipv6_pool)

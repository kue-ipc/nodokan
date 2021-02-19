import ApplicationRecord from './application_record'
import IpPool from './ip_pool'
import Ip6Pool from './ip6_pool'
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
      ip_address, ip_mask, ip_gateway, ip6_address, ip6_prefix, ip6_gateway,
      ip_pools, ip6_pools, props...}) ->
    super(props)
    console.log "#{ip_address}/#{ip_mask}"
    @ip_network = if ip_address? then ipaddr.parse("#{ip_address}/#{ip_mask}")
    @ip_gateway = if ip_gateway? then ipaddr.parse(ip_gateway)
    @ip6_network = if ip6_address? then ipaddr.parse("#{ip6_address}/#{ip_prefix}")
    @ip6_gateway = if ip6_gateway? then ipaddr.parse(ip6_gateway)
    @ip_pools = ip_pools.map (ip_pool) -> new IpPool(ip_pool)
    @ip6_pools = ip6_pools.mpa (ip6_pool) -> new Ip6Pool(ip6_pool)

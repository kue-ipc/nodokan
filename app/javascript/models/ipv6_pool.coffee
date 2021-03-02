import ApplicationRecord from './application_record'
import ipaddr from 'ipaddr.js'

export default class Ipv6Pool extends ApplicationRecord
  constructor: ({@ipv6_config, ipv6_first_address, ipv6_last_address, props...}) ->
    super(props)
    @ipv6_first_address = ipaddr.parse(ipv6_first_address)
    @ipv6_last_address = ipaddr.parse(ipv6_last_address)

  ip_config: -> @ipv6_config

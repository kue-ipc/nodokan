import ApplicationRecord from './application_record'
import ipaddr from 'ipaddr.js'

export default class Ip6Pool extends ApplicationRecord
  constructor: ({@ip6_config, ip6_first_address, ip6_last_address, props...}) ->
    super(props)
    @ip6_first_address = ipaddr.parse(ip6_first_address)
    @ip6_last_address = ipaddr.parse(ip6_first_address)

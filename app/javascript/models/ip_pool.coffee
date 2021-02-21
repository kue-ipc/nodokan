import ApplicationRecord from './application_record'
import ipaddr from 'ipaddr.js'

export default class IpPool extends ApplicationRecord
  constructor: ({@ip_config, ip_first_address, ip_last_address, props...}) ->
    super(props)
    @ip_first_address = ipaddr.parse(ip_first_address)
    @ip_last_address = ipaddr.parse(ip_last_address)

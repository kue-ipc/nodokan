import ApplicationRecord from './application_record'
import ipaddr from 'ipaddr.js'

export default class Ipv4Pool extends ApplicationRecord
  constructor: ({@ipv4_config, ipv4_first_address, ipv4_last_address, props...}) ->
    super(props)
    @ipv4_first_address = ipaddr.parse(ipv4_first_address)
    @ipv4_last_address = ipaddr.parse(ipv4_last_address)

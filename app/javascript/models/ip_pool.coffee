import ApplicationRecord from './application_record'
import ipaddr from 'ipaddr.js'

export default class IpPool extends ApplicationRecord
  constructor: ({@ip_config, first_address, last_addres, props...}) ->
    super(props)
    @first_address = ipaddr.pares(first_address)
    @last_address = ipaddr.pares(last_address)

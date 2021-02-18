import ApplicationRecord from './application_recored'
import ipaddr from 'ipaddr.js'

export default class Ip6Pool extends ApplicationRecord
  constructor: ({@ip6_config, first6_address, last6_addres,sprops...}) ->
    super(props)
    @first_address = ipaddr.pares(first_address)
    @last_address = ipaddr.pares(last_address)

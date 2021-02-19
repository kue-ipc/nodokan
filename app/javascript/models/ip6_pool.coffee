import ApplicationRecord from './application_record'
import ipaddr from 'ipaddr.js'

export default class Ip6Pool extends ApplicationRecord
  constructor: ({@ip6_config, first6_address, last6_addres, props...}) ->
    super(props)
    @first6_address = ipaddr.pares(first6_address)
    @last6_address = ipaddr.pares(last6_address)

# NodeのNICを色々操作するためのJavaScript

import {listToSnake, listToField} from 'modules/string_utils'
import ipaddr from 'ipaddr.js'

console.log ipaddr

NETWORK_MAP = new Map

fetchNetwork = (id) ->
  unless id? and /^\d+$/.test(id)
    return null

  if NETWORK_MAP.has(id)
    return NETWORK_MAP.get(id)

  url = "/networks/#{id}.json"

  response = await fetch(url)
  data = await response.json()

  NETWORK_MAP.set(id, data)
  data

class NodeNic
  @NAMES = [
    '_destroy'
    'interface_type'
    'name'
    'network_id'
    'mac_address'
    'duid'
    'ip_config'
    'ip_address'
    'ip6_config'
    'ip6_address'
  ]

  constructor: (@number, @role) ->
    @prefixList = ['node', 'nics_attributes', @number.toString()]
    @admin = @role == 'admin'

    @rootNode = @getNode()
    @inputs = {}
    for name in NodeNic.NAMES
      node = @getNode(name)
      @inputs[name] = {
        node
        initialValue: node.value
      }

    @inputs['_destroy'].node.addEventListener 'change', (_e) =>
      @checkDestroy()

    @inputs['interface_type'].node.addEventListener 'change', (_e) =>
      @checkInterfaceType()

    @inputs['network_id'].node.addEventListener 'change', (_e) =>
      @applyNetwork()

    @checkDestroy()

  getNodeId: (names...) ->
    listToSnake(@prefixList..., names...)

  getNode: (names...) ->
    document.getElementById(@getNodeId(names...))

  checkDestroy: ->
    if @inputs['_destroy'].node.checked
      @disableInputs(
        'interface_type'
        'name'
        'network_id'
        'mac_address'
        'duid'
        'ip_config'
        'ip_address'
        'ip6_config'
        'ip6_address'
      )
      return

    @enableInputs('interface_type')
    @checkInterfaceType()

  checkInterfaceType: ->
    value = @inputs['interface_type'].node.value
    if not value? or value.length == 0
      @disableInputs(
        'name'
        'network_id'
        'mac_address'
        'duid'
        'ip_config'
        'ip_address'
        'ip6_config'
        'ip6_address'
      )
      return

    @enableInputs(
      'name'
      'network_id'
      'mac_address'
      'duid'
    )
    @applyNetwork()

  disableInputs: (names...) ->
    for name in names
      @inputs[name].node.disabled = true

  enableInputs: (names...) ->
    for name in names
      @inputs[name].node.disabled = false

  applyNetwork: (@networkId = @inputs['network_id'].node.value) ->
    network = await fetchNetwork(@networkId)

    console.log network

    unless network?
      @inputs['ip_config'].node.selectedIndex = 0
      @inputs['ip_config'].node.disabled = true

      @inputs['ip_address'].node.value = ''
      @inputs['ip_address'].node.disabled = true

      @inputs['ip6_config'].node.selectedIndex = 0
      @inputs['ip6_config'].node.disabled = true

      @inputs['ip6_address'].node.value = ''
      @inputs['ip6_address'].node.disabled = true

      @inputs['mac_address'].node.required = false
      return

    @inputs['mac_address'].node.required = network['auth']

    # 可能なIP設定
    availableIpConfigs = new Set
    availableIpConfigs.add('disabled')
    if network['ip_address']?
      for ipPool in network['ip_pools']
        switch ipPool['ip_config']
          when 'static'
            availableIpConfigs.add('static')
          when 'reserved'
            if network['dhcp']
              availableIpConfigs.add('reserved')
          when 'dynamic'
            if network['dhcp']
              availableIpConfigs.add('dynamic')
      if not network['dhcp'] and network['closed']
        availableIpConfigs.add('link_local')
    else
      availableIpConfigs.add('link_local')

    # 可能なIPv6設定
    availableIp6Configs = new Set
    availableIp6Configs.add('disabled')
    if network['ip6_address']?
      for ip6Pool in network['ip6_pools']
        switch ip6Pool['ip6_config']
          when 'static'
            availableIp6Configs.add('static')
          when 'reserved'
            if network['dhcp']
              availableIp6Configs.add('reserved')
          when 'dynamic'
            # DHCPでなくても自動は可能
            availableIp6Configs.add('dynamic')
    else
      availableIp6Configs.add('link_local')

    console.log availableIpConfigs
    console.log availableIp6Configs

    for option in @inputs['ip_config'].node.options
      if availableIpConfigs.has(option.value)
        option.disabled = false
      else
        option.disabled = true

    for option in @inputs['ip6_config'].node.options
      if availableIp6Configs.has(option.value)
        option.disabled = false
      else
        option.disabled = true

    @inputs['ip_config'].node.disabled = false
    @inputs['ip_address'].node.disabled = false
    @inputs['ip6_config'].node.disabled = false
    @inputs['ip6_address'].node.disabled = false

info = JSON.parse(document.getElementById('node-nic-info').textContent)
new NodeNic(id, info.role) for id in info.list


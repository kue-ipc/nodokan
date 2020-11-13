# NodeのNICを色々操作するためのJavaScript

import {listToSnake, listToField} from 'modules/string_utils'

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
  constructor: (@number, @role) ->
    @prefixList = ['node', 'nics_attributes', @number.toString()]
    @admin = @role == 'admin'

    @rootNode = @getNode()
    @inputNodes = {}
    for name in [
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
      @inputNodes[name] = @getNode(name)

    @ipAddress = @inputNodes['ip_address'].value
    @ip6Address = @inputNodes['ip6_address'].value

    destroyCheckboxNode = @getNode('_destroy')
    destroyCheckboxNode.addEventListener 'change', (e) =>
      if e.target.checked
        @disableForm()
      else
        @enableForm()

    @applyNetwork()
    @inputNodes['network_id'].addEventListener 'change', (_e) =>
      @applyNetwork()

  getNodeId: (names...) ->
    listToSnake(@prefixList..., names...)

  getNode: (names...) ->
    document.getElementById(@getNodeId(names...))

  disableForm: ->
    for node in Object.values(@inputNodes)
      node.disabled = true

  enableForm: ->
    for name in [
      'interface_type'
      'name'
      'network_id'
      'mac_address'
      'duid'
    ]
      @inputNodes[name].disabled = false

    @applyNetwork()

  applyNetwork: (@networkId = @inputNodes['network_id'].value) ->
    network = await fetchNetwork(@networkId)

    console.log network

    unless network?
      @inputNodes['ip_config'].selectedIndex = 0
      @inputNodes['ip_config'].disabled = true

      @inputNodes['ip_address'].value = ''
      @inputNodes['ip_address'].disabled = true

      @inputNodes['ip6_config'].selectedIndex = 0
      @inputNodes['ip6_config'].disabled = true

      @inputNodes['ip6_address'].value = ''
      @inputNodes['ip6_address'].disabled = true

      @inputNodes['mac_address'].required = false
      return

    @inputNodes['mac_address'].required = network['auth']

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

    for option in @inputNodes['ip_config'].options
      if availableIpConfigs.has(option.value)
        option.disabled = false
      else
        option.disabled = true

    for option in @inputNodes['ip6_config'].options
      if availableIp6Configs.has(option.value)
        option.disabled = false
      else
        option.disabled = true

    @inputNodes['ip_config'].disabled = false
    @inputNodes['ip_address'].disabled = false
    @inputNodes['ip6_config'].disabled = false
    @inputNodes['ip6_address'].disabled = false





info = JSON.parse(document.getElementById('node-nic-info').textContent)
new NodeNic(id, info.role) for id in info.list


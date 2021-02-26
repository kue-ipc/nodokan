# NodeのNICを操作するためのJavaScript

import {listToSnake, listToField} from 'modules/string_utils'
import Network from 'models/network'
import ipaddr from 'ipaddr.js'

# NETWORK_MAP = new Map

# fetchNetwork = (id) ->
#   unless id? and /^\d+$/.test(id)
#     return null

#   if NETWORK_MAP.has(id)
#     return NETWORK_MAP.get(id)

#   url = "/networks/#{id}.json"

#   response = await fetch(url)
#   data = await response.json()

#   NETWORK_MAP.set(id, data)
#   data

class NodeNic
  @NAMES = [
    '_destroy'
    'interface_type'
    'name'
    'network_id'
    'mac_address'
    'duid'
    'ipv4_config'
    'ipv6_config'
  ]

  constructor: (@number, @role) ->
    @prefixList = ['node', 'nics_attributes', @number.toString()]
    @admin = @role == 'admin'

    @rootNode = @getNode()
    @inputs = {}
    for name in NodeNic.NAMES
      node = @getNode(name)
      if node?
        @inputs[name] = {
          node
          initialValue: node.value
        }

    @networkMessageNode = @getNode('network_message')
    @badges = [
      {
        name: 'auth'
        node: @getNode('badge_auth')
        level: 'danger'
      }
      {
        name: 'dhcp'
        node: @getNode('badge_dhcp')
        level: 'primary'
      }
      {
        name: 'closed'
        node: @getNode('badge_closed')
        level: 'danger'
      }
    ]

    @inputs['_destroy'].node.addEventListener 'change', (_e) =>
      @checkDestroy()

    @inputs['interface_type'].node.addEventListener 'change', (_e) =>
      @checkInterfaceType()

    @inputs['network_id'].node.addEventListener 'change', (_e) =>
      @checkNetwork()

    @checkDestroy()

  getNodeId: (names...) ->
    listToSnake(@prefixList..., names...)

  getNode: (names...) ->
    document.getElementById(@getNodeId(names...))

  disableInputs: (names...) ->
    for name in names
      @inputs[name]?.node?.disabled = true

  enableInputs: (names...) ->
    for name in names
      @inputs[name]?.node?.disabled = false

  checkDestroy: ->
    if @inputs['_destroy'].node.checked
      @disableInputs(
        'interface_type'
        'name'
        'network_id'
        'mac_address'
        'duid'
        'ipv4_config'
        'ipv6_config'
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
        'ipv4_config'
        'ipv6_config'
      )
      return

    @enableInputs(
      'name'
      'network_id'
      'mac_address'
      'duid'
    )
    @checkNetwork()

  checkNetwork: (@networkId = @inputs['network_id'].node.value) ->
    unless @networkId? && @networkId != ''
      @inputs['ipv4_config']?.node?.selectedIndex = 0
      @inputs['ipv6_config']?.node?.selectedIndex = 0

      @disableInputs('ipv4_config', 'ipv6_config')
      for {node} in @badges
        node.className = 'badge badge-light text-muted'

      return

    network = await Network.fetch(@networkId)

    unless network?
      @disableInputs('ipv4_config', 'ipv6_config')

      @inputs['ipv4_config'].node.selectedIndex = 0
      @inputs['ipv6_config'].node.selectedIndex = 0

      @inputs['mac_address'].node.required = false

      for {node} in @badges
        node.className = 'badge badge-light text-muted'

      return

    if network['auth']
      @networkMessageNode.textContent = '認証ネットワークに接続するには、MACアドレスが必要です。'
      # 管理者の場合は必須としない
      @inputs['mac_address'].node.required = !@admin
    else
      @networkMessageNode.textContent = ''
      @inputs['mac_address'].node.required = false

    for {name, node, level} in @badges
      if network[name]
        node.className = "badge badge-#{level}"
      else
        node.className = 'badge badge-light text-muted'

    # 可能なIP設定
    availableIpConfigs = new Set
    availableIpConfigs.add('disabled')
    if network['ipv4_address']?
      for ipPool in network['ipv4_pools']
        switch ipPool['ipv4_config']
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
      if @admin
        # 管理者は固定で設定可能
        availableIpConfigs.add('static')
    else
      availableIpConfigs.add('link_local')

    # 可能なIPv6設定
    availableIp6Configs = new Set
    availableIp6Configs.add('disabled')
    if network['ipv6_address']?
      for ipv6Pool in network['ipv6_pools']
        switch ipv6Pool['ipv6_config']
          when 'static'
            availableIp6Configs.add('static')
          when 'reserved'
            if network['dhcp']
              availableIp6Configs.add('reserved')
          when 'dynamic'
            # DHCPでなくても自動は可能
            availableIp6Configs.add('dynamic')
      if @admin
        # 管理者は固定で設定可能
        availableIp6Configs.add('static')
    else
      availableIp6Configs.add('link_local')

    for option in @inputs['ipv4_config']?.node?.options ? []
      if availableIpConfigs.has(option.value)
        option.disabled = false
      else
        option.disabled = true

    for option in @inputs['ipv6_config']?.node?.options ? []
      if availableIp6Configs.has(option.value)
        option.disabled = false
      else
        option.disabled = true

    @enableInputs('ipv4_config', 'ipv6_config')

info = JSON.parse(document.getElementById('node-nic-info').textContent)
new NodeNic(id) for id in info.list

# NodeのNICを操作するためのJavaScript

import {listToSnake, listToField} from 'modules/string_utils'
import Network from 'models/network'
import ipaddr from 'ipaddr.js'

class NodeNic
  @NAMES = [
    '_destroy'
    'interface_type'
    'name'
    'network_id'
    'mac_registration'
    'mac_address'
  ]

  @NAMES_IP = {
    ipv4: ['ipv4_config']
    ipv6: ['ipv6_config', 'duid']
  }

  constructor: (@number, {ipv6 = true}) ->
    @prefixList = ['node', 'nics_attributes', @number.toString()]

    @ip_versions = ['ipv4']
    @ip_versions.push('ipv6') if ipv6
    @ip_configs = @ip_versions.map((ip_version) -> "#{ip_version}_config")

    @names = [NodeNic.NAMES...]
    for ip_version in @ip_versions
      @names = [@names..., NodeNic.NAMES_IP[ip_version]...]

    @rootNode = @getNode()
    @inputs = new Map(
      for name in @names
        node = @getNode(name)
        init = {
          value: node.value
          checked: node.checked
          selectedIndex: node.selectedIndex
        }
        options =
          if node?.tagName?.toUpperCase() == 'SELECT'
            new Map([optionNode.value, {node: optionNode, index}] for optionNode, index in node.options ? [])
        [name, {node, init, options}]
    )

    @networkMessageNode = @getNode('network_message')

    @inputs.get('_destroy').node.addEventListener 'change', (_e) => @changeDestroy()
    @inputs.get('interface_type').node.addEventListener 'change', (_e) => @changeInterfaceType()
    @inputs.get('network_id').node.addEventListener 'change', (_e) => @changeNetwork()

    @inputs.get('mac_registration').node.addEventListener 'change', (_e) => @requireMacAddress()
    @inputs.get('ipv4_config').node.addEventListener 'change', (_e) => @requireMacAddress()
    @inputs.get('ipv6_config').node.addEventListener 'change', (_e) => @requireDuid()

    @requireMacAddress()
    @requireDuid()
    @changeDestroy()

  getNodeId: (names...) ->
    listToSnake(@prefixList..., names...)

  getNode: (names...) ->
    document.getElementById(@getNodeId(names...))

  disableInputs: (names, {excludes = []} = {}) ->
    for name in names when !excludes.includes(name)
      @inputs.get(name)?.node?.disabled = true

  enableInputs: (names, {excludes = []} = {}) ->
    for name in names when !excludes.includes(name)
      @inputs.get(name)?.node?.disabled = false

  adjustSelect: (name, list) ->
    {node, init, options} = @inputs.get(name)
    selectedIndex = -1
    disabledIndex = -1
    availableIndices = []
    for [value, option] from options
      disabledIndex = option.index if value == 'disabled'

      if list.includes(value)
        availableIndices.push(option.index)
        selectedIndex = option.index if option.node.selected
        option.node.disabled = false
      else
        option.node.disabled = true

    node.selectedIndex =
      if selectedIndex >= 0 && selectedIndex != disabledIndex
        selectedIndex
      else if @checkInitInput('network_id')
        init.selectedIndex
      else
        availableIndices[0] ? -1

  requireMacAddress: ->
    @inputs.get('mac_address').node.required =
      @inputs.get('mac_registration').node.checked ||
      @inputs.get('ipv4_config').node.value == 'reserved'

  requireDuid: ->
    @inputs.get('duid').node.required =
      @inputs.get('ipv6_config').node.value == 'reserved'

  setInitInput: (name) ->
    {node, init} = @inputs.get(name)
    switch node.tagName.toUpperCase()
      when 'INPUT'
        if node.getAttribute('type').toLowerCase() == 'checkbox'
          node.checked = init.checked
        else
          node.value = init.value
      when 'SELECT'
        node.selectedIndex = init.selectedIndex

  checkInitInput: (name) ->
    {node, init} = @inputs.get(name)
    switch node.tagName.toUpperCase()
      when 'INPUT'
        if node.getAttribute('type').toLowerCase() == 'checkbox'
          node.checked == init.checked
        else
          node.value == init.value
      when 'SELECT'
        node.selectedIndex == init.selectedIndex
      else
        false

  changeDestroy: ->
    if @inputs.get('_destroy').node.checked
      @disableInputs(@names, excludes: ['_destroy'])
      return

    @enableInputs(['interface_type'])
    @changeInterfaceType()

  changeInterfaceType: ->
    unless @inputs.get('interface_type').node.value
      @disableInputs(@names, excludes: ['_destroy', 'interface_type'])
      return

    @enableInputs(['name', 'network_id', 'mac_address', 'duid'])
    @changeNetwork()

  changeNetwork: ->
    @networkMessageNode.innerText = ''

    networkId = @inputs.get('network_id').node.value
    unless networkId
      for name in @ip_configs
        @adjustSelect(name, ['disabled'])
      @disableInputs(@ip_configs)

      @inputs.get('mac_registration').node.checked = false
      @requireMacAddress()
      @disableInputs(['mac_registration'])

      @networkMessageNode.innerText = '''
        どのネットワークにも接続していません。接続するネットワークを選択してください。
      '''
      return

    network = await Network.fetch(networkId)

    # 設定不可能なネットワーク
    unless network?
      for name in @ip_configs
        @setInitInput(name)
      @disableInputs(@ip_configs)

      @setInitInput('mac_registration')
      @requireMacAddress()
      @disableInputs(['mac_registration'])

      @networkMessageNode.innerText = '''
        あなたの権限では設定できないネットワークが設定されています。
        これは既存の接続を維持するために管理者によって設定されました。
        設定を変更したい場合は別のネットワークを選択してください。
        ただし、ネットワークの変更を一度設定した後に元のネットワークに戻すことはできません。
      '''
      return

    messages = []

    if network['auth']
      messages.push("このネットワークは認証ネットワークです。")
      if @checkInitInput('network_id')
        @setInitInput('mac_registration')
      else
        @inputs.get('mac_registration').node.checked = true
      @requireMacAddress()
      @enableInputs(['mac_registration'])
    else
      @inputs.get('mac_registration').node.checked = false
      @requireMacAddress()
      @disableInputs(['mac_registration'])

    # 可能なIP設定
    for name in @ip_configs
      @adjustSelect(name, network["#{name}_list"])
    @enableInputs(@ip_configs)

    @requireMacAddress()
    @requireDuid()

    @networkMessageNode.innerText = messages.join("\n")


info = JSON.parse(document.getElementById('node-nic-info').textContent)
new NodeNic(id, ipv6: info.ipv6) for id in info.list

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
    'auth'
    'mac_address'
  ]

  @NAMES_IP = {
    ipv4: ['ipv4_config', 'ipv4_address']
    ipv6: ['ipv6_config', 'ipv6_address', 'duid']
  }

  @MESSAGES = [
    'no_network'
    'auth_network'
    'require_mac'
    'require_duid'
    'network_note'
  ]

  constructor: (@number, {@ipv6 = true, @address_placeholders = {}}) ->
    @prefixList = ['node', 'nics_attributes', @number.toString()]

    @ip_versions = ['ipv4']
    @ip_versions.push('ipv6') if @ipv6
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
            new Map(
              for optionNode, index in node.options ? []
                [optionNode.value, {node: optionNode, index}]
            )
        [name, {node, init, options}]
    )

    @messages = new Map(
      for name in NodeNic.MESSAGES
        node = @getNode('message', name)
        [name, {node}]
    )

    @inputs.get('_destroy').node.addEventListener 'change', (_e) =>
      @changeDestroy()
    @inputs.get('interface_type').node.addEventListener 'change', (_e) =>
      @changeInterfaceType()
    @inputs.get('network_id').node.addEventListener 'change', (_e) =>
      @changeNetwork()

    @inputs.get('auth').node.addEventListener 'change', (_e) =>
      @requireMacAddress()
    @inputs.get('ipv4_config').node.addEventListener 'change', (e) =>
      @requireMacAddress()
      @adjustAddress('ipv4', e.target.value)

    if @ipv6
      @inputs.get('ipv6_config').node.addEventListener 'change', (e) =>
        @requireDuid()
        @adjustAddress('ipv6', e.target.value)

    @requireMacAddress()
    @requireDuid()

    @network = null
    # all check
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

  displayMessage: (name, message = null) ->
    node = @messages.get(name).node
    node.textContent = message if message?
    node.classList.remove('d-none')

  hideMessage: (name) ->
    node.classList.add('d-none')

  hideAllMessages: ->
    for [key, value] from @messages
      value.node.classList.add('d-none')

  adjustConfig: (ip, list) ->
    config_name = ip + '_config'
    {node, init, options} = @inputs.get(config_name)
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

    @adjustAddress(ip, node.value)

  adjustAddress: (ip, config) ->
    address_name = ip + '_address'
    config_name = ip + '_config'

    {node, init, options} = @inputs.get(address_name)

    node.placeholder = @address_placeholders[config]
    if @network?.id?.toString() == @inputs.get('network_id').init.value &&
        config == @inputs.get(config_name).init.value
      node.value = init.value || ''
    else
      node.value = ''

    if !@network?.managable or ['dynamic', 'disabled'].includes(config)
      node.disabled = true
    else
      node.disabled = false

  requireMacAddress: ->
    if @inputs.get('auth').node.checked ||
        @inputs.get('ipv4_config').node.value == 'reserved'
      @inputs.get('mac_address').node.required = true
      @displayMessage('require_mac')
    else
      @inputs.get('mac_address').node.required = false

  requireDuid: ->
    if @inputs.get('ipv6_config').node.value == 'reserved'
      @inputs.get('duid').node.required = true
      @displayMessage('require_duid')
    else
      @inputs.get('duid').node.required = false

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
    @hideAllMessages()

    networkId = @inputs.get('network_id').node.value
    unless networkId
      @network = null
      for ip in @ip_versions
        @adjustConfig(ip, ['disabled'])
      @disableInputs(@ip_configs)

      @inputs.get('auth').node.checked = false
      @requireMacAddress()
      @disableInputs(['auth'])

      @displayMessage('no_network')
      return

    @network = await Network.fetch(networkId)

    unless @network?
      for name in @ip_configs
        @setInitInput(name)
      @disableInputs(@ip_configs)

      @setInitInput('auth')
      @requireMacAddress()
      @disableInputs(['auth'])

      @displayMessage('unconfigurable')
      return

    if @network['auth']
      @displayMessage('auth_network')

      if @checkInitInput('network_id')
        @setInitInput('auth')
      else
        @inputs.get('auth').node.checked = true
      @requireMacAddress()
      @enableInputs(['auth'])
    else
      @inputs.get('auth').node.checked = false
      @requireMacAddress()
      @disableInputs(['auth'])

    for ip in @ip_versions
      @adjustConfig(ip, @network["#{ip}_config_list"])
    @enableInputs(@ip_configs)

    @requireMacAddress()
    @requireDuid()

    if @network['note']
      @displayMessage('network_note', @network['note'])

info = JSON.parse(document.getElementById('node-nic-info').textContent)
for id in info.list
  new NodeNic(id, info.options)

# specific node application

document.addEventListener 'turbolinks:load', ->
  reasonText = document.getElementById('specific_node_application_reason')
  return unless reasonText?

  actionRadioMap = new Map
  for el in document.getElementsByName('specific_node_application[action]')
    actionRadioMap.set(el.value, el)

  ruleSetRadioMap = new Map
  for el in document.getElementsByName('specific_node_application[rule_set]')
    ruleSetRadioMap.set(el.value, el)

  externalSelect = document.getElementById('specific_node_application_external')

  ruleListTextArea = document.getElementById('specific_node_application_rule_list')

  registerDnsCheckBox = document.getElementById('specific_node_application_register_dns')

  fqdnText = document.getElementById('specific_node_application_fqdn')

  labelFor = (el) ->
    document.querySelector("label[for=\"#{el.id}\"]")

  setRequired = (list...) ->
    for el in list
      el.required = true
      labelFor(el)?.classList?.add('required')

  unsetRequired = (list...) ->
    for el in list
      el.required = false
      labelFor(el)?.classList?.remove('required')

  setDisabled = (list...) ->
    for el in list
      el.disabled = true

  unsetDisabled = (list...) ->
    for el in list
      el.disabled = false

  checkAction = ->
    if actionRadioMap.get('release').checked
      setDisabled(
        ruleSetRadioMap.values()...,
        externalSelect,
        ruleListTextArea,
        registerDnsCheckBox,
        fqdnText,
      )
    else
      unsetDisabled(
        ruleSetRadioMap.values()...,
        externalSelect,
        ruleListTextArea,
        registerDnsCheckBox,
        fqdnText,
      )
    checkRuleSet()

  checkRuleSet = ->
    for el from ruleSetRadioMap.values()
      continue unless el.checked

      if Number(el.value) >= 0
        for option in externalSelect.getElementsByTagName('option')
          if option.value == el.dataset.external
            option.selected = true
            option.disabled = false
          else
            option.selected = false
            option.disabled = true

        ruleListTextArea.value = JSON.parse(el.dataset.list).join("\n")
        ruleListTextArea.readOnly = true

        if ['true', '1', 'on'].includes(el.dataset.dns.toLowerCase())
          registerDnsCheckBox.previousElementSibling.value = '1'
          registerDnsCheckBox.checked = true
        else
          registerDnsCheckBox.previousElementSibling.value = '0'
          registerDnsCheckBox.checked = false
        registerDnsCheckBox.disabled = true

        unsetRequired(externalSelect, ruleListTextArea, registerDnsCheckBox)

      else
        for option in externalSelect.getElementsByTagName('option')
          option.selected = false
          option.disabled = false

        ruleListTextArea.value = ''
        ruleListTextArea.readOnly = false

        registerDnsCheckBox.previousElementSibling.value = '0'
        registerDnsCheckBox.checked = false
        registerDnsCheckBox.disabled = false

        setRequired(externalSelect, ruleListTextArea, registerDnsCheckBox)

      checkDns()
      break

  checkExternal = ->
    if ['none', 'direct'].includes(externalSelect.value)
      ruleListTextArea.value = ''
      ruleListTextArea.readOnly = true
      unsetRequired(ruleListTextArea)
    else
      ruleListTextArea.readOnly = false
      setRequired(ruleListTextArea)

  checkDns = ->
    if registerDnsCheckBox.checked
      setRequired(fqdnText)
    else
      unsetRequired(fqdnText)

  for el from actionRadioMap.values()
    el.addEventListener 'click', ->
      checkAction()

  for el from ruleSetRadioMap.values()
    el.addEventListener 'click', ->
      checkRuleSet()

  externalSelect.addEventListener 'click', ->
    checkExternal()

  registerDnsCheckBox.addEventListener 'click', ->
    checkDns()

  checkAction()


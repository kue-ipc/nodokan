# specific node application

externalSelect = document.getElementById('specific_node_application_external')
ruleListTextArea = document.getElementById('specific_node_application_rule_list')
registerDnsCheckBox = document.getElementById('specific_node_application_register_dns')
fqdnInput = document.getElementById('specific_node_application_fqdn')

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

modifyRuleList = (el) ->
  if el.checked
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

for el in document.querySelectorAll('input[name="specific_node_application[rule_set]"]')
  modifyRuleList(el)
  el.addEventListener 'click', (e) ->
    modifyRuleList(e.target)

checkDns = ->
  if registerDnsCheckBox.checked
    setRequired(fqdnInput)
  else
    unsetRequired(fqdnInput)

checkDns()

registerDnsCheckBox.addEventListener 'click', ->
  checkDns()


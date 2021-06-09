# specific node application

externalSelect = document.getElementById('specific_node_application_external')
ruleListTextArea = document.getElementById('specific_node_application_rule_list')
registerDnsCheckBox = document.getElementById('specific_node_application_register_dns')

modifyRuleList = (el) ->
  if el.checked
    if Number(el.value) >= 0
      ruleListTextArea.readOnly = true
      registerDnsCheckBox.readOnly = true

      for option in externalSelect.getElementsByTagName('option')
        if option.value == el.dataset.external
          option.selected = true
          option.disabled = false
        else
          option.selected = false
          option.disabled = true
      ruleListTextArea.value = JSON.parse(el.dataset.list).join("\n")
      registerDnsCheckBox.checked = el.dataset.dns
    else
      ruleListTextArea.readOnly = false
      registerDnsCheckBox.readOnly = false
      for option in externalSelect.getElementsByTagName('option')
        option.disabled = false


for el in document.querySelectorAll('input[name="specific_node_application[rule_set]"]')
  modifyRuleList(el)
  el.addEventListener 'click', (e) ->
    modifyRuleList(e.target)

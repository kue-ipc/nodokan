import FlagCollapse from '../utils/flag_collapse.coffee'

document.addEventListener 'turbo:load', ->
  for name in ['logical', 'virtual_machine', 'specific', 'public', 'dns']
    id = "node_#{name}"
    el = document.getElementById(id)
    return unless el?

    new FlagCollapse(el, {name})

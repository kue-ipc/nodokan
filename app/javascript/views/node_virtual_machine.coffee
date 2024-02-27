import FlagCollapse from '../utils/flag_collapse.coffee'

document.addEventListener 'turbo:load', ->
  el = document.getElementById('node_virtual_machine')
  return unless el?

  new FlagCollapse(el, name: 'virtual_machine')

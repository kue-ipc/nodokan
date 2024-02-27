import FlagCollapse from '../utils/flag_collapse.coffee'

document.addEventListener 'turbo:load', ->
  el = document.getElementById('node_logical')
  return unless el?

  new FlagCollapse(el, name: 'logical')

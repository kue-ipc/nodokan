document.addEventListener 'turbo:load', ->
  nodeLogical = document.getElementById('node_logical')
  return unless nodeLogical?

  logicalOn = ->
    for el in document.getElementsByClassName('logical-hide')
      el.classList.add('d-none')
    for el in document.getElementsByClassName('logical-show')
      el.classList.remove('d-none')

  logicalOff = ->
    for el in document.getElementsByClassName('logical-hide')
      el.classList.remove('d-none')
    for el in document.getElementsByClassName('logical-show')
      el.classList.add('d-none')

  changeLogical = ->
    if nodeLogical.checked
      logicalOn()
    else
      logicalOff()

  nodeLogical.addEventListener 'change', changeLogical

  changeLogical()

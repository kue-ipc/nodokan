document.addEventListener 'turbolinks:load', ->
  nodeVirtual = document.getElementById('node_virtual')
  return unless nodeVirtual?

  virtualOn = ->
    for el in document.getElementsByClassName('virtual-hide')
      el.classList.add('d-none')
    for el in document.getElementsByClassName('virtual-show')
      el.classList.remove('d-none')

  virtualOff = ->
    for el in document.getElementsByClassName('virtual-hide')
      el.classList.remove('d-none')
    for el in document.getElementsByClassName('virtual-show')
      el.classList.add('d-none')

  changeVirtual = ->
    if nodeVirtual.checked
      virtualOn()
    else
      virtualOff()

  nodeVirtual.addEventListener 'change', changeVirtual

  changeVirtual()

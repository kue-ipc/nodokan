nodeVirtual = document.getElementById('node_virtual')

virtualOn = ->
  for el in document.getElementsByClassName('virtual-hide')
    el.classList.add('d-none')

virtualOff = ->
  for el in document.getElementsByClassName('virtual-hide')
    el.classList.remove('d-none')

changeVirtual = ->
  if nodeVirtual.checked
    virtualOn()
  else
    virtualOff()

nodeVirtual.addEventListener 'change', changeVirtual

changeVirtual()

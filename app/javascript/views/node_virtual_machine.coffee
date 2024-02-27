document.addEventListener 'turbo:load', ->
  nodeVirtualMachine = document.getElementById('node_virtual_machine')
  return unless nodeVirtualMachine?

  virtualMachineOn = ->
    for el in document.getElementsByClassName('virtual_machine-hide')
      el.classList.add('d-none')
    for el in document.getElementsByClassName('virtual_machine-show')
      el.classList.remove('d-none')

  virtualMachineOff = ->
    for el in document.getElementsByClassName('virtual_machine-hide')
      el.classList.remove('d-none')
    for el in document.getElementsByClassName('virtual_machine-show')
      el.classList.add('d-none')

  changeVirtualMachine = ->
    if nodeVirtualMachine.checked
      virtualMachineOn()
    else
      virtualMachineOff()

  nodeVirtualMachine.addEventListener 'change', changeVirtualMachine

  changeVirtualMachine()

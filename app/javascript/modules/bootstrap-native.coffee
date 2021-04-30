import bsn from 'bootstrap.native'

bsnComponentSelectors = [
  {component: bsn.Alert,     selector: '[data-dismiss="alert"]'}
  {component: bsn.Button,    selector: '[data-toggle="buttons"]'}
  {component: bsn.Carousel,  selector: '[data-ride="carousel"]'}
  {component: bsn.Collapse,  selector: '[data-toggle="collapse"]'}
  {component: bsn.Dropdown,  selector: '[data-toggle="dropdown"]'}
  {component: bsn.Modal,     selector: '[data-toggle="modal"]'}
  {component: bsn.Popover,   selector: '[data-toggle="popover"]'}
  {component: bsn.ScrollSpy, selector: '[data-spy="scroll"]'}
  {component: bsn.Tab,       selector: '[data-toggle="tab"]'}
  {component: bsn.Toast,     selector: '[data-dismiss="toast"]'}
  {component: bsn.Tooltip,   selector: '[data-toggle="tooltip"]'}
]

document.addEventListener 'turbolinks:load', ->
  for {component, selector} in bsnComponentSelectors
    for el in document.querySelectorAll selector
      new component(el)
, false

global.bsn = bsn

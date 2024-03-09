# bootstrap components
# Alert, Button, Carousel, Collapse, Dropdown, Modal, Offcanvas, Popover,
#   ScrollSpy, Tab, Toast, Tooltip
import * as bootstrap from 'bootstrap'

# default allow list custmized
customDefaultAllowList = bootstrap.Tooltip.Default.allowList
customDefaultAllowList.dl = []
customDefaultAllowList.dt = []
customDefaultAllowList.dd = []

bootstrapComponentSelectors = [
  {component: bootstrap.Popover, selector: '[data-bs-toggle="popover"]'}
  {component: bootstrap.Tooltip, selector: '[data-bs-toggle="tooltip"]'}
]

bootstrapEnbaleComponents = ->
  for {component, selector, option = {}} in bootstrapComponentSelectors
    for el in document.querySelectorAll selector
      new component(el, option)

document.addEventListener 'turbo:load', ->
  console.debug "toggle bootstrp by turbo:load"
  bootstrapEnbaleComponents()

document.addEventListener 'turbo:frame-load', ->
  console.debug "toggle bootstrp by turbo:frame-load"
  bootstrapEnbaleComponents()

globalThis.bootstrap = bootstrap

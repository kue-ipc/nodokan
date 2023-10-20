# bootstrap components
# Alert, Button, Carousel, Collapse, Dropdown, Modal, Offcanvas, Popover, ScrollSpy, Tab, Toast, Tooltip
import * as bootstrap from 'bootstrap'

bootstrapComponentSelectors = [
  {component: bootstrap.Popover,   selector: '[data-bs-toggle="popover"]'}
  {component: bootstrap.Tooltip,   selector: '[data-bs-toggle="tooltip"]'}
]

document.addEventListener 'turbo:load', ->
  for {component, selector} in bootstrapComponentSelectors
    for el in document.querySelectorAll selector
      new component(el)

globalThis.bootstrap = bootstrap

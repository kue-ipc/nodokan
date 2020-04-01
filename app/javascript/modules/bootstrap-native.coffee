import bsn from 'bootstrap.native/dist/bootstrap-native-v4'
document.addEventListener 'turbolinks:load', ->
  [
    [bsn.Alert, '[data-dismiss="alert"]']
    [bsn.Button, '[data-toggle="buttons"]']
    [bsn.Carousel, '[data-ride="carousel"]']
    [bsn.Collapse, '[data-toggle="collapse"]']
    [bsn.Dropdown, '[data-toggle="dropdown"]']
    [bsn.Modal, '[data-toggle="modal"]']
    [bsn.Popover, '[data-toggle="popover"]']
    [bsn.ScrollSpy, '[data-spy="scroll"]']
    [bsn.Tab, '[data-toggle="tab"]']
    [bsn.Toast, '[data-dismiss="toast"]']
    [bsn.Tooltip, '[data-toggle="tooltip"]']
  ].forEach ([component, selector]) ->
    for el in document.querySelectorAll selector
      new component(el)
, false

global.bsn = bsn

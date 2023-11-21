# GET nodes/:id
# confirmation form

import {Collapse, Modal} from 'bootstrap'

class NodeConfirm
  constructor: (@modalEl) ->
    @modal = Modal.getOrCreateInstance(@modalEl)

    @modalEl.addEventListener 'shown.bs.modal', ->
      location.hash = 'confirm'

    @modalEl.addEventListener 'hidden.bs.modal', ->
      location.hash = ''

    @collapseEl = document.getElementById('node-confirm-collapse')
    @collapse = Collapse.getOrCreateInstance(@collapseEl, toggle: false)

    @collapseEl.addEventListener 'shown.bs.collapse', =>
      for el in @collapseEl.querySelectorAll('input,select') when el.type != 'checkbox'
        el.required = true

    @collapseEl.addEventListener 'hidden.bs.collapse', =>
      for el in @collapseEl.querySelectorAll('input,select') when el.type != 'checkbox'
        el.required = false

    for el in document.querySelectorAll('input[name="confirmation[existence]"]')
      if el.value == 'existing'
        @collapse.show() if el.checked

        el.addEventListener 'change', =>
          @collapse.show()
      else
        el.addEventListener 'change', =>
          @collapse.hide()

    ['os_update', 'app_update'].forEach (attrName) =>
      collapseSecuredEl = document.getElementById("node-confirm-secured-#{attrName}")
      collapseSecured = Collapse.getOrCreateInstance(collapseSecuredEl, toggle: false)
      for el in document.querySelectorAll("input[name=\"confirmation[#{attrName}]\"]")
        if el.value == 'secured'
          collapseSecured.show() if el.checked

          el.addEventListener 'change', =>
            collapseSecured.show()
        else
          el.addEventListener 'change', =>
            collapseSecured.hide()
    ['security_hardwares'].forEach (attrName) =>
      ["none", "unknown"]
      checkElList = document.getElementsByName("confirmation[#{attrName}][]")
      noneCheckEl = document.getElementById("confirmation_#{attrName}_none")
      unknownCheckEl = document.getElementById("confirmation_#{attrName}_unknown")

      noneCheckEl.addEventListener 'change', =>
        for el in checkElList when el != noneCheckEl
          el.checked = false

      unknownCheckEl.addEventListener 'change', =>
        for el in checkElList when el != unknownCheckEl
          el.checked = false

      for el in checkElList when ![noneCheckEl, unknownCheckEl].includes(el)
        el.addEventListener 'change', =>
          noneCheckEl.checked = false
          unknownCheckEl.checked = false

  modalShow: ->
    @modal.show()

document.addEventListener 'turbo:load', ->
  modalEl = document.getElementById('node-confirm-modal')
  if modalEl?
    nc = new NodeConfirm(modalEl)
    nc.modalShow() if location.hash == '#confirm'


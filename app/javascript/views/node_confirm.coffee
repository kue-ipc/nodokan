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
    @collapseShown = false

    @collapseEl.addEventListener 'shown.bs.collapse', =>
      @collapseShown = true
      for el in @collapseEl.querySelectorAll('input,select') when el.type != 'checkbox'
        el.required = true

    @collapseEl.addEventListener 'hidden.bs.collapse', =>
      @collapseShown = false
      for el in @collapseEl.querySelectorAll('input,select') when el.type != 'checkbox'
        el.required = false
    

    for el in @modalEl.querySelectorAll('input[name="confirmation[existence]"]')
      if el.value == 'existing'
        @collapse.show() if el.checked

        el.addEventListener 'change', =>
          @collapse.show()
      else
        el.addEventListener 'change', =>
          @collapse.hide()

    ['os_update', 'app_update'].forEach (attrName) =>
      collapseSecuredEl =
        document.getElementById("node-confirm-secured-#{attrName}")
      collapseSecured =
        Collapse.getOrCreateInstance(collapseSecuredEl, toggle: false)
      for el in document.querySelectorAll("input[name=\"confirmation[#{attrName}]\"]")
        if el.value == 'secured'
          collapseSecured.show() if el.checked

          el.addEventListener 'change', =>
            collapseSecured.show()
        else
          el.addEventListener 'change', =>
            collapseSecured.hide()

    ['security_hardwares'].forEach (attrName) =>
      exclusiveValues = ['none', 'unknown']
      checkElList = document.getElementsByName("confirmation[#{attrName}][]")

      for el in checkElList
        el.addEventListener 'change', (event) =>
          if event.target.checked
            if exclusiveValues.includes(event.target.value)
              for otherEl in checkElList when otherEl.value != event.target.value
                otherEl.checked = false
            else
              for exclusiveEl in checkElList when exclusiveValues.includes(exclusiveEl.value)
                exclusiveEl.checked = false

    for el in document.getElementsByName("commit")
      el.addEventListener "click", (e) =>
        ['security_hardwares'].forEach (attrName) =>
          checkElList =
            document.getElementsByName("confirmation[#{attrName}][]")
          requiredFlag =
            @collapseShown &&
            (el for el in checkElList when el.checked).length == 0
          for el in checkElList
            el.required = requiredFlag

  modalShow: ->
    @modal.show()

document.addEventListener 'turbo:load', ->
  modalEl = document.getElementById('node-confirm-modal')
  if modalEl?
    nc = new NodeConfirm(modalEl)
    nc.modalShow() if location.hash == '#confirm'


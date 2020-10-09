# NodeのNICを色々操作するためのJavaScript

import {listToSnake, listToField} from 'modules/string_utils'

class NodeNic
  constructor: (@number) ->
    @prefixList = ['node', 'nics_attributes', @number.toString()]

    @rootElm = document.getElementById(listToSnake(@prefixList...))

    destroy_checkbox = document.getElementById(listToSnake(@prefixList..., '_destroy'))
    destroy_checkbox.addEventListener 'change', (e) =>
      if e.target.checked
        @disable_form()
      else
        @enable_form()


  disable_form: ->
    for elm in @rootElm.getElementsByClassName('node-nic-form')
      for tagName in ['input', 'select', 'textarea', 'button']
        for inputElm in elm.getElementsByTagName(tagName)
          inputElm.disabled = true

  enable_form: ->
    for elm in @rootElm.getElementsByClassName('node-nic-form')
      for tagName in ['input', 'select', 'textarea', 'button']
        for inputElm in elm.getElementsByTagName(tagName)
          inputElm.disabled = false

nicList = JSON.parse(document.getElementById('node-nic-list').getAttribute('data-list'))
new NodeNic(id) for id in nicList


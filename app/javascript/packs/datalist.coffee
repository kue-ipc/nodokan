# まったくもって書きかけ、方針が定まらない

import {h, text, app} from 'hyperapp'
import {request} from '@hyperapp/http'

class DatalistCandidation
  constructor: ({@parent, @name, @target, @attrList, @url}) ->

  getList: (aciton) ->
    request({
      url: @url
      expect: 'json'

    })



  watchAttr = (dispatch, {parent, name, attr}) ->
    watchNode = document.getElementById(id)

    handler = (e) ->
      dispatch([, {name: attr, value: e.target.value}])

    watchNode.addEventListner('onchange', handler)
    () -> watchNode.removeEventListener('onchange', handler)


  getInputValues = ({parent, name, attrList}) ->
    attrList.map (attr) ->
      {
        name: attr
        value: document.getElementById([parent, name, attr].join('_').value)
      }


  complementDatalist = ({parent, url, name, target, attrList}) ->
    node = document.getElementById("#{parent}_#{name}_#{target}-list")
    initialState = {
      url: url
      attrs: getInputValues({parent, name, attrList})
      list: []
    }

    app({
      init: [
        initialState
        request()
      ]
      view
      node: document.getElementById("#{parent}_#{name}_#{target}-list")
      subscriptions: (state) => attrList.map (attr) =>
        [watchAttr, {parent, name, attr}]
    }


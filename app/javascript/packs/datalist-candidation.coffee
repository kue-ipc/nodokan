# まったくもって書きかけ、方針が定まらない

import {h, text, app} from 'hyperapp'
import {request} from '@hyperapp/http'

class DatalistCandidation
  constructor: ({@parent, @name, @target, @inputList, @url}) ->
    @appId = [@attrId(@target), 'app'].join('-')
    @datalistId = [@attrId(@target), 'list'].join('-')
    @appNode = document.getElementById(@appId)
    @inputNodeList = for attr in @inputList
      {
        name: attr
        node: document.getElementById(@attrId(attr))
      }
    @initialState = {
      attrs: @inputValues()
      list: []
    }

  getResult: (state, data) =>
    list = data
      .sort (a, b) -> b.nodes_count - a.nodes_count
      .map (data) -> data.name
    {
      state...
      list
    }

  createUrl: (attrs) ->
    list = ("#{attr.name}=#{encodeURIComponent(attr.value)}" for attr in attrs)
    @url + '?' + list.join('&')

  view: (state) =>
    h 'datalist', id: @datalistId,
      for value in state.list
        h 'option', {value}

  subscriptions: (state) =>
    [@watchAttr, {attr}] for attr in @inputList

  getData: (url) =>
    request
      url: url
      expect: 'json'
      action: @getResult

  run: ->
    app({
      init: [
        @initialState
        @getData(@createUrl(@initialState.attrs))
      ]
      view: @view
      node: @appNode
      subscriptions: @subscriptions
    })

  attrId: (attr) ->
    [@parent, @name, attr].join('_')

  inputValues: ->
    for {name, node} in @inputNodeList
      {
        name
        value: node.value
      }

  watchAttr: (dispatch, {attr}) =>
    watchId = @attrId(attr)
    watchNode = document.getElementById(watchId)

    handler = (e) =>
      dispatch(@watchChange, {name: attr, value: e.target.value})

    watchNode.addEventListener('change', handler)
    -> watchNode.removeEventListener('change', handler)

  watchChange: (state, {name, value}) =>
    newAttrs = for attr in state.attrs
      if attr.name == name
        {name, value}
      else
        attr
    [
      {
        state...
        attrs: newAttrs
      }
      @getData(@createUrl(newAttrs))
    ]

for node in document.getElementsByClassName('datalist-canadidaiton')
  dc = new DatalistCandidation(JSON.parse(node.getAttribute('data-params')))
  dc.run()

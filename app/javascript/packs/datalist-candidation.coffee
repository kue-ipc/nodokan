import {h, text, app} from 'hyperapp'
# import {request} from '@hyperapp/http'

class DatalistCandidation
  constructor: ({
    @parent, @name, @target, @order, @inputList, @url,
    @requiredInput = null,
    @per = 100,
    @description = false
  }) ->
    @targetId = @attrId(@target)
    @appId = [@targetId, 'app'].join('-')
    @datalistId = [@targetId, 'list'].join('-')
    @descriptionId = [@targetId, 'description'].join('-')

    @targetNode = document.getElementById(@targetId)
    @appNode = document.getElementById(@appId)
    @descriptionNode = document.getElementById(@descriptionId)

    @inputAttrList = for name in @inputList
      {
        name
        node: document.getElementById(@attrId(name))
        required: name == @requiredInput
      }
    @initialState = {
      attrs: @inputValues()
      list: []
    }
    @data = []
    @targetDescriptions = new Map

  getResult: (state, data) =>
    @data = data['data']
    list = []
    for entry in @data
      list.push(entry[@target])
      if @description
        @targetDescriptions.set(entry[@target], entry['description'])
    @updateDescription() if @description
    {
      state...
      list
    }

  createUrl: (attrs) ->
    list = []
    list.push("per=#{@per}")
    unless @description
      list.push("target=#{@target}")
    if @order?
      for k, v of @order
        list.push("order[#{k}]=#{v}")
    for attr in attrs
      list.push("condition[#{attr.name}]=#{encodeURIComponent(attr.value)}")
    @url + '?' + list.join('&')

  view: (state) =>
    h 'datalist', id: @datalistId,
      for value in state.list
        h 'option', {value}

  subscriptions: (state) =>
    [@watchAttr, attr] for attr in @inputAttrList

  clearList: (state) =>
    {
      state...
      list: []
    }

  getData: (attrs) =>
    if (0 for {value} in attrs when !value? || value == '').length > 0
      return [(dispatch, props) => dispatch(@clearList, props), {}]

    url = @createUrl(attrs)
    request
      url: url
      expect: 'json'
      action: @getResult

  run: ->
    app({
      init: [
        @initialState
        @getData(@initialState.attrs)
      ]
      view: @view
      node: @appNode
      subscriptions: @subscriptions
    })

    if @description
      @targetNode.addEventListener 'change', @updateDescription

  attrId: (attr) ->
    [@parent, @name, attr].join('_')

  inputValues: ->
    for {name, node, required} in @inputAttrList
      value = node.value
      if required
        if value? and value.length > 0
          @targetNode.disabled = false
        else
          @targetNode.disabled = true
      {name, value}

  watchAttr: (dispatch, {name, node, required}) =>
    watchId = @attrId(name)

    handler = (e) =>
      dispatch(@watchChange, {name, value: e.target.value, required})

    node.addEventListener('change', handler)
    -> node.removeEventListener('change', handler)

  watchChange: (state, {name, value, required}) =>
    newAttrs = for attr in state.attrs
      if attr.name == name
        {name, value}
      else
        attr

    if required
      if value? and value.length > 0
        @targetNode.disabled = false
      else
        @targetNode.disabled = true
        return {
          state...
          attrs: newAttrs
        }

    [
      {
        state...
        attrs: newAttrs
      }
      @getData(newAttrs)
    ]

  updateDescription: =>
    message = @targetDescriptions.get(@targetNode.value)
    @descriptionNode.textContent = message ? ''

for node in document.getElementsByClassName('datalist-canadidaiton')
  dc = new DatalistCandidation(JSON.parse(node.getAttribute('data-params')))
  dc.run()

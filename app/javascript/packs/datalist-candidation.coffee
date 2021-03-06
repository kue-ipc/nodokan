# DatalisntCandidation#constructor
# parent: 親のモデルの名前
# name: モデルの名前
# target: 対象となる属性
# order: リストの順番
# inputList: 条件の参照となるinputのリスト
# url: indexのJSONのパス
# requiredInput: 検索するときに入力が必須であるinput
# per: 検索するアイテム数上限
# description: 説明があるかどうか
# clear: 変更時にクリアまたは初期値に戻すかどうか
# locked: 変更不可になるもの
# required: 入力必須になるもの

class DatalistCandidation
  constructor: ({
    @parent, @name, @target, @order, @inputList, @url,
    @requiredInput = null,
    @per = 1000,
    @description = false,
    @clear = false,
    @locked = null,
    @required = null,
  }) ->
    @targetId = @attrId(@target)
    @appId = [@targetId, 'app'].join('-')
    @datalistId = [@targetId, 'list'].join('-')
    @descriptionId = [@targetId, 'description'].join('-')

    @targetNode = document.getElementById(@targetId)
    @targetNodeLabel = document.querySelector("label[for='#{@targetId}']")
    @initialValue = @targetNode.value

    @appNode = document.getElementById(@appId)
    @descriptionNode = document.getElementById(@descriptionId)

    @attrList = for name in @inputList
      node = document.getElementById(@attrId(name))
      {
        name
        node
        required: name == @requiredInput
      }

    @data = []
    @targetDescriptions = new Map

  attrId: (attr) ->
    [@parent, @name, attr].join('_')

  createUrl: ->
    list = []
    list.push("per=#{@per}")
    unless @description
      list.push("target=#{@target}")
    if @order?
      for k, v of @order
        list.push("order[#{k}]=#{v}")
    for attr in @attrList
      list.push("condition[#{attr.name}]=#{encodeURIComponent(attr.value)}")
    @url + '?' + list.join('&')

  checkAttrValues: ->
    for attr in @attrList
      attr.value = attr.node.value

  checkAvailable: ->
    # check all required
    if @attrList.some ({value, required}) -> required and not value
      @targetNode.disabled = true
      false
    else
      @targetNode.disabled = false
      true

  getData: () ->
    return [] unless @attrList.every ({value}) -> value

    url = @createUrl()
    response = await fetch(url)
    result = await response.json()
    result['data']

  updateDatalist: (_) =>
    @checkAttrValues()
    return unless @checkAvailable()

    data = await @getData()

    if @clear
      @targetNode.value =
        if data.some (entry) => @initialValue == entry[@target]
          @initialValue
        else
          ''

    if @locked
      if (attr for attr in @attrList when attr.name is @locked.name and @locked.list.includes(attr.value))[0]?
        @targetNode.readOnly = true
        @targetNodeLabel.classList.add('readonly')
        @targetNode.value = data[0][@target]
      else
        @targetNodeLabel.classList.remove('readonly')
        @targetNode.readOnly = false

    if @required
      if (attr for attr in @attrList when attr.name is @required.name and @required.list.includes(attr.value))[0]?
        @targetNode.required = true
        @targetNodeLabel.classList.add('required')
      else
        @targetNode.required = false
        @targetNodeLabel.classList.remove('required')

    # update datalist
    listNode = document.createElement('datalist')
    listNode.id = @datalistId
    for entry in data
      itemNode = document.createElement('option')
      itemNode.setAttribute('value', entry[@target])
      itemNode.textContent = entry[@target]
      listNode.appendChild(itemNode)
    currentListNode = document.getElementById(@datalistId)
    if currentListNode
      @appNode.replaceChild(listNode, document.getElementById(@datalistId))
    else
      @appNode.appendChild(listNode)

    # update description list
    if @description
      @targetDescriptions.clear()
      for entry in data
        @targetDescriptions.set(entry[@target], entry['description'])
      @updateDescription()

  updateDescription: (_) =>
    message = @targetDescriptions.get(@targetNode.value)
    @descriptionNode.textContent = message ? ''

  run: ->
    for {node} in @attrList
      node.addEventListener 'change', @updateDatalist

    if @description
      @targetNode.addEventListener 'change', @updateDescription

    @updateDatalist()

for node in document.getElementsByClassName('datalist-canadidaiton')
  dc = new DatalistCandidation(JSON.parse(node.getAttribute('data-params')))
  dc.run()

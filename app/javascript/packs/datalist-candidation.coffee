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
    list = []

    @targetDescriptions.clear()
    for entry in data
      list.push(entry[@target])
      if @description
        @targetDescriptions.set(entry[@target], entry['description'])

    listNode = document.createElement('datalist')
    listNode.id = @datalistId
    for value in list
      itemNode = document.createElement('option')
      itemNode.textContent = value
      listNode.appendChild(itemNode)

    currentListNode = document.getElementById(@datalistId)
    if currentListNode
      @appNode.replaceChild(listNode, document.getElementById(@datalistId))
    else
      @appNode.appendChild(listNode)

    @updateDescription() if @description

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

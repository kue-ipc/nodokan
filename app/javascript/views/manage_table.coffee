import {app, h, text} from 'hyperapp'
import csrf from '../utils/csrf.civet'

HIDDEN_ATTRIBUTES = new Set([
  'created_at'
  'updated_at'
])

SORT_TEXT = {
  sort: '⇅'
  up: '↑'
  down: '↓'
}

PAGINATION_TEXT = {
  first: '« first'
  last: 'last »'
  previous: '‹ prev'
  next: 'next ›'
  truncate: '…'
}

DEFAULT_PER_PAGE = 100
PER_PAGES = [10, 25, 50, 100, 500, 1000]

convertSearchParams = (obj, prefix = '') ->
  convertSearchParamsList(obj, prefix)
    .map (item) ->
      "#{encodeURIComponent(item[0])}=#{encodeURIComponent(item[1])}"
    .join("&")

convertSearchParamsList = (obj, prefix = '') ->
  list = []
  for own key, value of obj
    continue unless value

    name =
      if prefix
        "#{prefix}[#{key}]"
      else
        "#{key}"

    switch typeof value
      when 'undefined'
        console.warn "undefined type appeared"
      when 'boolean'
        list.push([name, if value then '1' else '0'])
      when 'number', 'bigint', 'string', 'symbol'
        list.push([name, String(value)])
      when 'function'
        console.warn "function type appeared"
      when 'object'
        if value instanceof Array
          for v in value
            list.push(["#{name}[]", v])
        else
          list = list.concat(convertSearchParamsList(value, name))
      else
        console.err "unknown type: #{typeof value}"
  list

view = ({model, entities, page, params}) ->
  if model? && entities?
    h 'div', {}, [
      h 'table', {class: ['table', 'table-sm']}, [
        thead({model, params})
        tbody({model, entities})
      ]
      pageNav({page})
      pageInfo({page})
      pagePer({params})
    ]
  else
    h 'p', {}, text 'loading...'

thead = ({model, params}) ->
  h 'thead', {},
    h 'tr', {}, model.attributes.map (attribute) ->
      return if HIDDEN_ATTRIBUTES.has(attribute.name)

      h 'th', {}, [
        text attribute.human_name
        h 'button', {
          class: 'btn btn-link'
          onclick: [switchSort, attribute.name]
        }, text(
          switch params.order?[attribute.name]
            when 'asc', 'ASC'
              SORT_TEXT.down
            when 'desc', 'DESC'
              SORT_TEXT.up
            else
              SORT_TEXT.sort
        )
      ]

switchSort = (state, name) ->
  url = state.url
  newTargetOrder =
    switch state.params.order?[name]
      when 'asc', 'ASC'
        'desc'
      when 'desc', 'DESC'
        undefined
      else
        'asc'
  params = {
    ...state.params
    order: {
      [name]: newTargetOrder
    }
  }
  [
    {...state, params}
    [fetchAll, {url, params}]
  ]

tbody = ({model, entities}) ->
  h 'tbody', {},
    entities.map (entity) -> row({model, entity})

row = ({model, entity}) ->
  if entity.edit
    editRow({model, entity})
  else
    showRow({model, entity})

showRow = ({model, entity}) ->
  id = "#{model.param_key}-#{entity.id}"
  h 'tr', {key: id, id: "tr-#{id}"},
    model.attributes.map (attribute) ->
      return if HIDDEN_ATTRIBUTES.has(attribute.name)

      attributeId = "#{id}-#{attribute.name}"
      h 'td', {key: attributeId, id: "td-#{attributeId}"},
        text entity[attribute.name] ? ''
    .concat [
      h 'td', {},
        h 'input',
          class: 'btn btn-warning btn-sm'
          type: 'button'
          value: 'edit'
          onclick: [updateEntity, {id: entity.id, name: 'edit', value: true}]
    ]

editRow = ({model, entity}) ->
  id = "#{model.param_key}-#{entity.id}"
  h 'tr', {key: id, id: "tr-#{id}"},
    model.attributes.map (attribute) ->
      return if HIDDEN_ATTRIBUTES.has(attribute.name)

      attributeId = "#{id}-#{attribute.name}"
      h 'td', {key: attributeId, id: "td-#{attributeId}"},
        if attribute.readonly
          text entity[attribute.name] ? ''
        else
          switch attribute.type
            when 'string'
              h 'input',
                id: attributeId
                class: 'form-control'
                type: 'text'
                value: entity[attribute.name]
                onchange: (state, event) ->
                  [updateEntity, {
                    id: entity.id
                    name: attribute.name
                    value: event.target.value
                  }]
            when 'integer'
              h 'input',
                id: attributeId
                class: 'form-control'
                type: 'number'
                value: entity[attribute.name]
                onchange: (state, event) ->
                  [updateEntity, {
                    id: entity.id
                    name: attribute.name
                    value: event.target.value
                  }]
            when 'boolean'
              h 'div', class: 'form-check', [
                h 'input',
                  type: 'checkbox'
                  id: attributeId
                  class: 'form-check-input'
                  checked: entity[attribute.name]
                  onchange: (state, event) ->
                    [updateEntity, {
                      id: entity.id
                      name: attribute.name
                      value: event.target.checked
                    }]
                h 'label',
                  class: 'form-check-label'
                  for: attributeId
              ]
            when 'date'
              h 'input',
                id: attributeId
                class: 'form-control'
                type: 'date'
                value: entity[attribute.name]
                onchange: (state, event) ->
                  [updateEntity, {
                    id: entity.id
                    name: attribute.name
                    value: event.target.value
                  }]
            when 'text'
              h 'textarea',
                id: attributeId
                class: 'form-control'
                onchange: (state, event) ->
                  [updateEntity, {
                    id: entity.id
                    name: attribute.name
                    value: event.target.value
                  }]
                text entity[attribute.name] ? ''

    .concat [
      h 'td', {},
        h 'input',
          class: 'btn btn-primary btn-sm'
          type: 'button'
          value: 'save'
          onclick: [saveEntity, {id: entity.id, model}]
    ]

pageNav = ({page}) ->
  pageLinkList = []
  if page.current != 1
    pageLinkList.push({key: 'frist', page: 1, text: PAGINATION_TEXT.first})
    pageLinkList.push({
      key: 'previous', page: page.current - 1, text: PAGINATION_TEXT.previous})
  if page.current >= 4
    pageLinkList.push({
      key: 'pre_truncate', text: PAGINATION_TEXT.truncate, disabled: true})
  if page.current >= 3
    pageLinkList.push({page: page.current - 2, text: "#{page.current - 2}"})
  if page.current >= 2
    pageLinkList.push({page: page.current - 1, text: "#{page.current - 1}"})
  pageLinkList.push({page: page.current, text: "#{page.current}", active: true})
  if page.current <= page.total - 1
    pageLinkList.push({page: page.current + 1, text: "#{page.current + 1}"})
  if page.current <= page.total - 2
    pageLinkList.push({page: page.current + 2, text: "#{page.current + 2}"})
  if page.current <= page.total - 3
    pageLinkList.push({
      key: 'post_truncate', text: PAGINATION_TEXT.truncate, disabled: true})
  if page.current != page.total
    pageLinkList.push({
      key: 'next', page: page.current + 1, text: PAGINATION_TEXT.next})
    pageLinkList.push({
      key: 'last', page: page.total, text: PAGINATION_TEXT.last})

  h 'nav', {},
    h 'ul', {class: 'pagination'}, pageLinkList.map (pageLink) ->
      h 'li', {
        key: pageLink.key || pageLink.page
        class: {
          'page-item': true, disabled: pageLink.disabled,
          active: pageLink.active}
      }, h 'button', {
        class: 'page-link'
        onclick: pageLink.page && [setPage, pageLink.page]
      },
        text pageLink.text

setPage = (state, page) ->
  url = state.url
  params = {...state.params, page: Number(page)}
  [
    {...state, params}
    [fetchAll, {url, params}]
  ]

pageInfo = ({page}) ->
  if page.current == page.total
    begin = page.count - page.size + 1
    end = page.count
  else
    begin = (page.current - 1) * page.size + 1
    end = begin + page.size - 1
  h 'p', {}, [
    text begin
    text '-'
    text end
    text '/'
    text page.count
  ]

pagePer = ({params}) ->
  h 'select', {
    class: 'form-select'
    onchange: setPerValue
  }, PER_PAGES.map (value) ->
    h 'option', {key: value, value, selected: params.per == value}, text value

setPerValue = (state, event) -> [setPer, event.target.value]

setPer = (state, per) ->
  url = state.url
  params = {...state.params, per: Number(per)}
  [
    {...state, params}
    [fetchAll, {url, params}]
  ]

updateEntity = (state, {id, name, value}) ->
  index = state.entities.findIndex (e) -> e.id == id
  entitiy = {
    ...state.entities[index]
    [name]: value
  }
  entities = [
    ...state.entities.slice(0, index)
    entitiy
    ...state.entities.slice(index + 1)
  ]
  {
    ...state
    entities
  }

saveEntity = (state, {id, model}) ->
  index = state.entities.findIndex (e) -> e.id == id
  entity = state.entities[index]
  [
    updateEntity(state, {id, name: 'edit', value: false})
    [putEntity, {model, entity}]
  ]

putEntity = (dispatch, {entity, model}) ->
  params =
    (attribute.name for attribute in model.attributes when !attribute.readonly)
  entityData = Object.fromEntries(([param, entity[param]] for param in params))

  putData = {
    ...csrf()
    [model.param_key]: entityData
  }

  response = await fetch entity.url,
    method: 'PUT'
    mode: 'same-origin'
    credentials: 'same-origin'
    headers:
      'Content-Type': 'application/json'
      'Accept': 'application/json'
    body: JSON.stringify(putData)

  newEntity = await response.json()

  requestAnimationFrame ->
    dispatch(mergeEntity, {entity, newEntity})

mergeEntity = (state, {entity, newEntity}) ->
  index = state.entities.findIndex (e) -> e.id == entity.id
  entities =
  if newEntity.id == entity.id
    [
      ...state.entities.slice(0, index)
      newEntity
      ...state.entities.slice(index + 1)
    ]
  else
    deletedEntities = [
      ...state.entities.slice(0, index)
      ...state.entities.slice(index + 1)
    ]
    newIndex = deletedEntities.findIndex (e) -> e.id == newEntity.id
    [
      ...deletedEntities.slice(0, newIndex)
      newEntity
      ...deletedEntities.slice(newIndex + 1)
    ]

  {
    ...state
    entities
  }

fetchAll = (dispatch, {url, params}) ->
  url = new URL(url)
  url.search = convertSearchParams(params)
  response = await fetch(url)
  data = await response.json()
  requestAnimationFrame ->
    dispatch(margeAll, data)

margeAll = (state, data) ->
  {
    ...state
    ...data
    params: {
      page: Number(data.params.page)
      per: Number(data.params.per)
      order: data.params.order
    }
  }

LOADED_ELEMENTS = new WeakSet()

export loadManageTable = (element) ->
  node = document.getElementById('manage-table')
  return unless node?

  if LOADED_ELEMENTS.has(node)
    console.warn "[manage_table] element is already loaded: #{node.id}"
    return

  url = node.dataset.url
  params = {
    page: 1,
    per: DEFAULT_PER_PAGE,
    order: {id: 'asc'},
  }
  init = [
    {url, params}
    [fetchAll, {url, params}]
  ]

  app {init, view, node}

  LOADED_ELEMENTS.add(node)

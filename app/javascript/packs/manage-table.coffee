import {app, h, text} from 'hyperapp'
import csrf from '../modules/csrf'

MASKED_ATTRIBUTES = [
  'id'
  'created_at'
  'updated_at'
]

view = ({model, entities}) ->
  if model? && entities?
    h 'table', {class: ['table', 'table-sm']}, [
      thead({model})
      tbody({model, entities})
    ]
  else
    h 'p', {}, text 'loading...'

thead = ({model}) ->
  h 'thead', {},
    h 'tr', {}, model.attributes.map (attribute) ->
      h 'th', {}, text attribute.human_name

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
  h 'tr', id: "tr-#{id}",
    model.attributes.map (attribute) ->
      attributeId = "#{id}-#{attribute.name}"
      h 'td', id: "td-#{attributeId}",
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
  h 'tr', id: "tr-#{id}",
    model.attributes.map (attribute) ->
      attributeId = "#{id}-#{attribute.name}"
      h 'td', id: "td-#{attributeId}",
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
              h 'div', class: 'custom-control custom-checkbox', [
                h 'input',
                  type: 'checkbox'
                  id: attributeId
                  class: 'custom-control-input'
                  checked: entity[attribute.name]
                  onchange: (state, event) ->
                    [updateEntity, {
                      id: entity.id
                      name: attribute.name
                      value: event.target.checked
                    }]
                h 'label',
                  class: 'custom-control-label'
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

updateEntity = (state, {id, name, value}) ->
  index = state.entities.findIndex (e) -> e.id == id
  entitiy = {
    state.entities[index]...
    [name]: value
  }
  entities = [
    state.entities.slice(0, index)...
    entitiy
    state.entities.slice(index + 1)...
  ]
  {
    state...
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
  params = (attribute.name for attribute in model.attributes when !attribute.readonly)
  entityData = Object.fromEntries([param, entity[param]] for param in params)

  putData = {
    csrf()...
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

  dispatch(mergeEntity, {entity, newEntity})

mergeEntity = (state, {entity, newEntity}) ->
  index = state.entities.findIndex (e) -> e.id == entity.id
  entities =
  if newEntity.id == entity.id
    [
      state.entities.slice(0, index)...
      newEntity
      state.entities.slice(index + 1)...
    ]
  else
    deletedEntities = [
      state.entities.slice(0, index)...
      state.entities.slice(index + 1)...
    ]
    newIndex = deletedEntities.findIndex (e) -> e.id == newEntity.id
    [
      deletedEntities.slice(0, newIndex)...
      newEntity
      deletedEntities.slice(newIndex + 1)...
    ]

  {
    state...
    entities
  }

fetchAll = (dispatch, url) ->
  response = await fetch(url)
  data = await response.json()
  dispatch(margeAll, data)

margeAll = (state, data) ->
  {
    state...
    data...
  }

main = ->
  node = document.getElementById('manage-table')
  url = node.dataset.url

  app
    init: -> [
      {url: url}
      [fetchAll, url]
    ]
    view: view
    node: document.getElementById('manage-table')

main()



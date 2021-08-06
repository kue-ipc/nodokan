import {app, h, text} from 'hyperapp'
import Place from 'models/place'
import {t} from 'modules/translation'

view = ({klass, list}) ->
  h 'table', {class: ['table', 'table-sm']}, [
    thead({klass})
    tbody({klass, list})
  ]

thead = ({klass}) ->
  h 'thead', {},
    h 'tr', {}, klass.attrs.map (attr) ->
      h 'th', {}, text t(['activerecord', 'attributes', klass.model_name().i18n_key, attr.name].join('.'))

tbody = ({klass, list}) ->
  h 'tbody', {},
    list.map (entity) -> row({klass, entity})

row = ({klass, entity}) ->
  if entity.edit
    row_edit({klass, entity})
  else
    row_show({klass, entity})

row_show = ({klass, entity}) ->
  id = "#{klass.param_key}-#{entity.id}"
  h 'tr', id: "tr-#{id}",
    klass.attrs.map (attr) ->
      attrId = "#{id}-#{attr.name}"
      h 'td', id: "td-#{attrId}",
        text entity[attr.name]
    .concat [
      h 'td', {},
        h 'input',
          class: 'btn btn-warning btn-sm'
          type: 'button'
          value: '編集'
          onclick: (state, event) ->
            entity.edit = true
            {state...}
    ]

row_edit = ({klass, entity}) ->
  id = "#{klass.param_key}-#{entity.id}"
  h 'tr', id: "tr-#{id}",
    klass.attrs.map (attr) ->
      attrId = "#{id}-#{attr.name}"
      h 'td', id: "td-#{attrId}",
        if attr.readonly
          text entity[attr.name]
        else
          switch attr.type
            when 'string'
              h 'input',
                id: attrId
                class: 'form-control'
                type: 'text'
                value: entity[attr.name]
                onchange: (state, event) ->
                  entity[attr.name] = event.target.value
                  {state...}
            when 'integer'
              h 'input',
                id: attrId
                class: 'form-control'
                type: 'number'
                value: entity[attr.name]
                onchange: (state, event) ->
                  entity[attr.name] = event.target.value
                  {state...}
            when 'boolean'
              h 'div', class: 'custom-control custom-checkbox', [
                h 'input',
                  type: 'checkbox'
                  id: attrId
                  class: 'custom-control-input'
                  checked: entity[attr.name]
                  onchange: (state, event) ->
                    entity[attr.name] = event.target.checked
                    {state...}
                h 'label',
                  class: 'custom-control-label'
                  for: attrId
              ]
    .concat [
      h 'td', {},
        h 'input',
          class: 'btn btn-primary btn-sm'
          type: 'button'
          value: '保存'
          onclick: (state, event) ->
            entity.update()
            entity.edit = false
            {state...}
    ]

margeList = (state, data) =>
  data

fetchList = (dispatch, url) =>
  response = await fetch(url)
  data = await response.json()
  dispatch(margeList, data)

main = ->
  node = document.getElementById('manage-table')
  url = node.dataset.url

  app
    init: => [
      {url: url}
      [fetchList, url]
    ]
    view: view
    node: document.getElementById('manage-table')

main()



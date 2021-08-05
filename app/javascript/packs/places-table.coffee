import {app, h, text} from 'hyperapp'
import Place from 'models/place'
import {t} from 'modules/translation'

thead = () ->
  h 'thead', {},
    h 'tr', {}, [
      h 'th', {}, text t('activerecord.attributes.place.area')
      h 'th', {}, text t('activerecord.attributes.place.building')
      h 'th', {}, text t('activerecord.attributes.place.floor')
      h 'th', {}, text t('activerecord.attributes.place.room')
      h 'th', {}, text t('activerecord.attributes.place.confirmed')
      h 'th', {}, text t('activerecord.attributes.place.nodes_count')
    ]

tbody = ({list}) ->
  h 'tbody', {},
    list.map (place) -> row({place})

row = ({place}) ->
  h 'tr', {}, [
    h 'td', {}, text place.area
    h 'td', {}, text place.building
    h 'td', {}, text place.floor
    h 'td', {}, text place.room
    h 'td', {}, text place.confirmed
    h 'td', {}, text place.nodes_count
  ]

view = (state) ->
  h 'table', {class: ['table', 'table-sm']}, [
    thead()
    tbody(state)
  ]

main = ->
  list = await Place.list({})
  console.log list[0]
  app {
    init: {list}
    view
    node: document.getElementById('places-table')
  }

main()


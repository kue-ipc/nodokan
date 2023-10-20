import ApplicationRecord from './application_record.coffee'
import csrf from '../utils/csrf.coffee'

export default class Place extends ApplicationRecord
  @attrs: [
    {name: 'area', type: 'string'}
    {name: 'building', type: 'string'}
    {name: 'floor', type: 'integer'}
    {name: 'room', type: 'string'}
    {name: 'confirmed', type: 'boolean'}
    {name: 'nodes_count', type: 'integer', readonly: true}
  ]

  @list: ({page, per, order, condition}) ->
    params = new URLSearchParams()
    
    params.append 'page', page if page?
    params.append 'per', per if per?
    if order?
      for k, v of order
        params.append "order[#{k}]", v
    if condition?
      for k, v of condition
        params.append "condition[#{k}]", v

    response = await fetch("/places.json?#{params}")

    data = await response.json()

    data.data.map (d) ->
      new Place(d)

  constructor: ({@area, @building, @floor, @room, @confirmed, @nodes_count, props...}) ->
    super(props)
    @edit = false

  update: ->
    {param, token} = csrf()
    data =
      [param]: token
      place:
        area: @area
        building: @building
        floor: @floor
        room: @room
        confirmed: @confirmed

    response = await fetch @url,
      method: 'PUT'
      mode: 'same-origin'
      credentials: 'same-origin'
      headers:
        'Content-Type': 'application/json'
        'Accept': 'application/json'
      body: JSON.stringify(data)

    data = await response.json()
    place = new Place(data)

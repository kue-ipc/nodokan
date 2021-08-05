import ApplicationRecord from './application_record'

export default class Place extends ApplicationRecord
  @places = new Map

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

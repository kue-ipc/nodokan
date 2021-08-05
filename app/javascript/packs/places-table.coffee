import {app, h, text} from 'hyperapp'
import Place from 'models/place'

main = ->
  list = await Place.list({})
  console.log list

main()

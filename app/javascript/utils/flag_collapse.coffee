import {Collapse} from 'bootstrap'

export default class FlagCollapse
  constructor: (@element, {@name}) ->
    @name ?= @element.id
    @showCollapse =
      for el in document.getElementsByClassName("collapse #{@name}-show")
        new Collapse(el, {toggle: false})
    @hideCollapse =
      for el in document.getElementsByClassName("collapse #{@name}-hide")
        new Collapse(el, {toggle: false})

    @element.addEventListener 'change', => @change()
    @change()

  change: ->
    if @element.checked
      @on()
    else
      @off()
  
  on: ->
    console.debug "#{@name} on"
    coll.hide() for coll in @hideCollapse
    coll.show() for coll in @showCollapse

  off: ->
    console.debug "#{@name} off"
    coll.hide() for coll in @showCollapse
    coll.show() for coll in @hideCollapse

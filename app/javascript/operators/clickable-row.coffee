# clickable-row
class ClickableRow
  @activeContextmenuNode = null

  constructor: (@node) ->
    @url = @node.dataset.href

    @node.addEventListener 'click', (e) =>
      window.location = @url

    @contextmenu = @node.dataset.contextmenu

    if @contextmenu
      @contextmenuNode = document.getElementById(@contextmenu)
      @node.addEventListener 'contextmenu', (e) =>
        e.preventDefault()
        if ClickableRow.activeContextmenuNode?
          ClickableRow.activeContextmenuNode.style.display = 'none'
        @contextmenuNode.style.left = e.pageX + 'px'
        @contextmenuNode.style.top = e.pageY + 'px'
        @contextmenuNode.style.display = 'block'
        ClickableRow.activeContextmenuNode = @contextmenuNode

document.addEventListener 'turbo:load', ->
  for node in document.getElementsByClassName('clickable-row')
    new ClickableRow(node)

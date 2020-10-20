# clickable-row
class ClickableRow
  constructor: (@node) ->
    @url = @node.dataset.href
    @node.addEventListener 'click', (e) =>
      window.location = @url

for node in document.getElementsByClassName('clickable-row')
  new ClickableRow(node)


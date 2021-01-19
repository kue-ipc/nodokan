# GET nodes/:id
# confirmation form

radioId = 'confirmation_existence_existing'
radioEl = document.getElementById(radioId)

collapseLinkId = 'node-confirm-collapse-link'
collapseLinkEl = document.getElementById(collapseLinkId)

collapesShown = false

for el in document.querySelectorAll 'input[name="confirmation[existence]"]'
  el.addEventListener 'change', (e) ->
    if e.target.value == 'existing'
      unless collapesShown
        collapseLinkEl.Collapse.show()
        collapesShown = true
    else
      if collapesShown
        collapseLinkEl.Collapse.hide()
        collapesShown = false

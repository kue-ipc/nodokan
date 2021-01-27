# GET nodes/:id
# confirmation form

radioId = 'confirmation_existence_existing'
radioEl = document.getElementById(radioId)

collapseLinkId = 'node-confirm-collapse-link'
collapseLinkEl = document.getElementById(collapseLinkId)

collapesShown = false

formModal = document.getElementById('confirm-form-modal')
formModal.addEventListener 'shown.bs.modal', (e) ->
  if document.getElementById('confirmation_existence_existing').checked
    unless collapesShown
      collapseLinkEl.Collapse.show()
      collapesShown = true

for el in document.querySelectorAll 'input[name="confirmation[existence]"]'
  if el.value == 'existing'
    el.addEventListener 'change', (e) ->
      unless collapesShown
        collapseLinkEl.Collapse.show()
        collapesShown = true
  else
    el.addEventListener 'change', (e) ->
      if collapesShown
        collapseLinkEl.Collapse.hide()
        collapesShown = false

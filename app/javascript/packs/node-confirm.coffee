# GET nodes/:id
# confirmation form

# Id and Element

formModalId = 'confirm-form-modal'
formModalEl = document.getElementById(formModalId)

formModalToggleId = 'confirm-form-modal-toggle'
formModalToggleEl = document.getElementById(formModalToggleId)

existingRadioId = 'confirmation_existence_existing'
existingRadioEl = document.getElementById(existingRadioId)

collapseLinkId = 'node-confirm-collapse-link'
collapseLinkEl = document.getElementById(collapseLinkId)

fieldsId = 'node-confirm-fields'
fieldsEl = document.getElementById(fieldsId)

# modal show

if location.hash == '#confirm'
  formModalToggleEl.Modal?.show()

document.addEventListener 'turbolinks:load', ->
  if location.hash == '#confirm'
    formModalToggleEl.Modal?.show()
, false

formModalEl.addEventListener 'shown.bs.modal', (e) ->
  location.hash = 'confirm'

formModalEl.addEventListener 'hidden.bs.modal', (e) ->
  location.hash = ''

# confirm collapse
fieldsEl.addEventListener 'shown.bs.collapse', (e) ->
  for el in fieldsEl.querySelectorAll('input,select')
    el.required = true

fieldsEl.addEventListener 'hidden.bs.collapse', (e) ->
  for el in fieldsEl.querySelectorAll('input,select')
    el.required = false

collapesShown = false

formModalEl.addEventListener 'shown.bs.modal', (e) ->
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



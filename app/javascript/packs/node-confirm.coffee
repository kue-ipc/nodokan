# GET nodes/:id
# confirmation form


radioId = 'confirmation_existence_existing'
radioEl = document.getElementById(radioId)

radioEl.addEventListener 'change', (e) ->
  console.log e

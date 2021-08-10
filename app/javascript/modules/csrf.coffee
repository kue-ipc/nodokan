export default csrf = ->
  param = (el for el in document.getElementsByName('csrf-param') when el.tagName == 'META')[0].content
  token = (el for el in document.getElementsByName('csrf-token') when el.tagName == 'META')[0].content
  {[param]: token}

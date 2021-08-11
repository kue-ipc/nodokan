translationMap = new Map
JsonNodeId = 'translation'
for key, value of JSON.parse(document.getElementById(JsonNodeId).textContent)
  translationMap.set(key ,value)

export t = (name) ->
  translationMap.get(name)
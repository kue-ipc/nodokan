# String Utils

# ['abc', 'xyz'] -> 'abcXyz'
export listToCamel = (list...) ->
  (list[0]?.toLowerCase() ? '') +
    (capitalize(str) for str in list[1..]).join('')

# ['abc', 'xyz'] -> 'AbcXyz'
export listToPascal = (list...) ->
  (capitalize(str) for str in list).join('')

# ['abc', 'xyz'] -> 'abc_xyz'
export listToSnake = (list...) ->
  (str.toLowerCase().replace(/-/g, '_') for str in list).join('_')

# ['abc', 'xyz'] -> 'abc-xyz'
export listToKebab = (list...) ->
  (str.toLowerCase().replace(/_/g, '-') for str in list).join('-')

# ['abc', 'xyz'] -> 'abc[xyz]'
export listToField = (list...) ->
  (list[0] ? '') +
    ("[#{str}]" for str in list[1..]).join('')

# 'abc_xyz' -> ['abc', 'xyz']
export strToList = (str) ->
  str.replace(/[A-Z]+/g, '_$&').toLowerCase().split(/[-_\s]+/)

# camelCase
export camelize = (str) ->
  listToCamel(strToList(str)...)

# PascalCase
export pascalize = (str) ->
  listToPascal(strToList(str)...)

# snake_case
export snakize = (str) ->
  listToSnake(strToList(str)...)

# kebab-case
export kebabize = (str) ->
  listToKebab(strToList(str)...)

# form[field][name]
export fieldize = (str) ->
  listToField(strToList(str)...)

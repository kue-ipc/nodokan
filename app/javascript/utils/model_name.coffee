import {snakize} from './string_utils.coffee'

export default class ModelName
  constructor: (@klass) ->
    @name = @klass.name

    @singular = snakize(@name)
    @plural = "#{@singular}s"

    @i18n_key = @singular
    @param_key = @singular
    @singular_route_key = @singular
    @element = @singular

    @collection = @plural
    @route_key = @plural

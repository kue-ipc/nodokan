import ModelName from '../utils/model_name.coffee'

export default class ApplicationRecord
  @model_name: ->
    @model_name_cache ?= new ModelName(@)

  constructor: ({@id, created_at, updated_at, @url = null}) ->
    @created_at = new Date(created_at)
    @updated_at = new Date(updated_at)

Object.defineProperty ApplicationRecord, 'param_key',
  get: -> @model_name().param_key

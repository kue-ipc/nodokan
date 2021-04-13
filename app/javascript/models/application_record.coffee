export default class ApplicationRecord
  constructor: ({@id, created_at, updated_at, @url = null}) ->
    @created_at = new Date(created_at)
    @updated_at = new Date(updated_at)

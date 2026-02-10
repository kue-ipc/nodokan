json.url request.url
json.params params
json.page do
  json.partial! "page", entities: @places
end
case @target
in nil
  json.model do
    json.partial! "model", model: Place
  end
  json.entities do
    json.array! @places, partial: "places/place", as: :place
  end
in :area | :building | :floor | :room
  json.ignore_nil!
  json.data do
    json.array! @places, @target
  end
end

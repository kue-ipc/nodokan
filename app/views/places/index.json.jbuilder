json.url request.url
json.pramas params
json.page do
  json.partial! 'page', entities: @places
end
json.model do
  json.partial! 'model', model: Place
end
if @target
  json.data do
    json.array! @places, @target
  end
else
  json.entities do
    json.array! @places, partial: 'places/place', as: :place
  end
end

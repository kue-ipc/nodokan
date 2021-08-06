json.pramas params
json.page do
  json.partial! 'page', entities: @places
end
json.class do
  json.partial! 'class', klass: Place
end
json.data do
  if @target
    json.array! @places, @target
  else
    json.array! @places, partial: 'places/place', as: :place
  end
end

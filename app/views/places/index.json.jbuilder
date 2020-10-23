json.pramas params
json.page do
  json.count @places.total_count
  json.size @places.size
  json.current @places.current_page
  json.total @places.total_pages
end
json.data do
  if @target
    json.array! @places, @target
  else
    json.array! @places, partial: 'places/place', as: :place
  end
end

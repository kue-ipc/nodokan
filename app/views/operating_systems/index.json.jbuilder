json.pramas params
json.page do
  json.count @operating_systems.total_count
  json.size @operating_systems.size
  json.current @operating_systems.current_page
  json.total @operating_systems.total_pages
end
json.data do
  if @target
    json.array! @operating_systems, [@target, :locked]
  else
    json.array! @operating_systems,
      partial: 'operating_systems/operating_system',
      as: :operating_system
  end
end

json.pramas params
json.page do
  json.count @hardwares.total_count
  json.size @hardwares.size
  json.current @hardwares.current_page
  json.total @hardwares.total_pages
end
json.data do
  if @target
    json.array! @hardwares, @target, :locked
  else
    json.array! @hardwares, partial: 'hardwares/hardware', as: :hardware
  end
end

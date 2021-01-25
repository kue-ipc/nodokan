json.pramas params
json.page do
  json.count @security_softwares.total_count
  json.size @security_softwares.size
  json.current @security_softwares.current_page
  json.total @security_softwares.total_pages
end
json.data do
  if @target
    json.array! @security_softwares, @target
  else
    json.array! @security_softwares,
      partial: 'security_softwares/security_software',
      as: :security_software
  end
end

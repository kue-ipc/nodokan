json.url request.url
json.pramas params
json.page do
  json.partial! "page", entities: @security_softwares
end
json.model do
  json.partial! "model", model: SecuritySoftware
end
if @target
  json.data do
    json.array! @security_softwares, :id, @target, :description
  end
else
  json.entities do
    json.array! @security_softwares, partial: "security_softwares/security_software", as: :security_software
  end
end

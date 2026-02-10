json.url request.url
json.params params
json.page do
  json.partial! "page", entities: @security_softwares
end
case @target
in nil
  json.model do
    json.partial! "model", model: SecuritySoftware
  end
  json.entities do
    json.array! @security_softwares, partial: "security_softwares/security_software", as: :security_software
  end
in :os_category_id
  json.ignore_nil!
  json.data do
    json.array! @security_softwares, @target
  end
in :installation_method
  json.ignore_nil!
  json.data do
    json.array! @security_softwares do |security_software|
      json.installation_method security_software.installation_method
      json.locked security_software.conf[:locked]
      json.required security_software.conf[:required]
    end
  end
in :name
  json.ignore_nil!
  json.data do
    json.array! @security_softwares, @target, :description
  end
end

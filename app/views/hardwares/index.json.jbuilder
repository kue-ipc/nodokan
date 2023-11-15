json.url request.url
json.params params
json.page do
  json.partial! "page", entities: @hardwares
end
json.model do
  json.partial! "model", model: Hardware
end
if @target
  json.data do
    json.array! @hardwares, @target
  end
else
  json.entities do
    json.array! @hardwares, partial: "hardwares/hardware", as: :hardware
  end
end

json.url request.url
json.params params
json.page do
  json.partial! "page", entities: @os_categories
end
json.model do
  json.partial! "model", model: OsCategory
end
json.entities do
  json.array! @os_categories, partial: "os_categories/os_category",
    as: :os_category
end

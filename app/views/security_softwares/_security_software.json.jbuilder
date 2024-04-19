json.extract! security_software, :id, :os_category_id, :installation_method,
  :name, :description, :approved, :confirmed, :confirmations_count,
  :created_at, :updated_at
json.url security_software_url(security_software)

def create_models(model_class)
  return unless model_class.count.zero?

  seeds_path = Rails.root / 'db' / 'seeds'
  file_name = "#{model_class.name.underscore.pluralize}.yml"
  yaml_file = seeds_path / file_name
  yaml_erb_file = seeds_path / "#{file_name}.erb"
  yaml_data =
    if yaml_file.exist?
      yaml_file.read
    else
      ERB.new(yaml_erb_file.read).result
    end
  YAML.safe_load(yaml_data, [Symbol, Time, Date], [], true,
    symbolize_names: false).each do |data|
    model_class.create!(data)
  end
end

create_models(DeviceType)
create_models(OsCategory)
create_models(OperatingSystem)
create_models(SecuritySoftware)

if Rails.env.development?
  create_models(Network)
end

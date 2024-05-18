def create_models(model_class)
  return unless model_class.count.zero?

  Rails.logger.debug do
    "model: #{model_class.name}"
  end

  seeds_path = Rails.root / "db" / "seeds"
  file_name = "#{model_class.name.underscore.pluralize}.yml"
  yaml_file = seeds_path / file_name
  yaml_erb_file = seeds_path / "#{file_name}.erb"
  yaml_data =
    if yaml_file.exist?
      yaml_file.read
    else
      ERB.new(yaml_erb_file.read).result
    end
  YAML.safe_load(yaml_data, permitted_classes: [Symbol, Time, Date],
    aliases: true, symbolize_names: false).each do |data|
    model = model_class.new(data)
    if model.save
      Rails.logger.debug { "succeeded to create: #{model.name}" }
    else
      Rails.logger.debug {
        "faild to create: #{model.name}: #{model.errors.to_json}"
      }
    end
  end
end

create_models(DeviceType)
# create_models(Hardware)

create_models(OsCategory)
create_models(OperatingSystem)
create_models(SecuritySoftware)

create_models(Network) if Rails.env.development?
create_models(Node) if Rails.env.development?

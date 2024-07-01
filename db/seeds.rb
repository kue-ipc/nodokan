def create_entities(model_class)
  return unless model_class.count.zero?

  start_msg = "create entities start: #{model_class.name}"
  puts start_msg
  Rails.logger.info("db:seed") { start_msg }
  start_time = Time.now
  count = {success: 0, failure: 0}

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
      count[:success] += 1
      Rails.logger.debug("db:seed") {
        "succeeded to create: #{model.name}"
      }
    else
      count[:failure] += 1
      Rails.logger.warn("db:seed") {
        "failed to create: #{model.name}: #{model.errors.to_json}"
      }
    end
  end

  end_time = Time.now
  end_msg = "create entities end: #{model_class.name} " \
            "[success: #{count[:success]}, failure: #{count[:failure]}] " \
            "(#{'%.4fs' % (end_time - start_time)})"
  puts end_msg
  Rails.logger.info("db:seed") { end_msg }
end

create_entities(DeviceType)
# create_entities(Hardware)

create_entities(OsCategory)
create_entities(OperatingSystem)
create_entities(SecuritySoftware)

create_entities(Network) if Rails.env.development?
create_entities(Node) if Rails.env.development?

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

seeds_path = Rails.root / 'db' / 'seeds'

if Network.count.zero?
  YAML.load_file(seeds_path / 'networks.yml').each do |data|
    Network.create(data)
  end
end

if OperatingSystem.count.zero?
  YAML.load_file(seeds_path / 'operating_systems.yml').each do |data|
    OperatingSystem.create(data)
  end
end

if SecuritySoftware.count.zero?
  YAML.load(ERB.new((seeds_path / 'security_softwares.yml.erb').read).result).each do |data|
    SecuritySoftware.create(data)
  end
end

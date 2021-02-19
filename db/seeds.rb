# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

seeds_path = Rails.root / 'db' / 'seeds'

YAML.load_file(seeds_path / 'networks.yml').each do |data|
  Network.create!(data) unless Network.find_by_name(data['name'])
end

YAML.load_file(seeds_path / 'operating_systems.yml').each do |data|
  OperatingSystem.create!(data) unless OperatingSystem.find_by_name(data['name'])
end

if SecuritySoftware.count.zero?
  YAML.load(ERB.new((seeds_path / 'security_softwares.yml.erb').read).result).each do |data|
    SecuritySoftware.create!(data)
  end
end

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

seeds_path = Rails.root / 'db' / 'seeds'

if Network.count.zero?
  YAML.load_file(seeds_path / 'networks.yml').each do |data|
    Network.create(data)
  end
end

YAML.load_file(seeds_path / 'operating_systems.yml').each do |data|
  os = OperatingSystem.find_or_initialize_by(name: data['name'])
  os.os_category = data['os_category']
  os.eol = os['eol']
  os.description = os['description']
  os.save
end

if SecuritySoftware.count.zero?
  YAML.load_file(seeds_path / 'security_softwares.yml').each do |data|
    SecuritySoftware.create(data)
  end
end
# SecuritySoftware.count.zero? && SecuritySoftware.create([
#   {
#     state: :built_in,
#     os_category: :windows_client,
#     name: 'Windows Defender',
#     approved: true,
#     description: 'Windows 10 標準のセキュリティ対策ソフトウェアです。',
#   },
#   {
#     state: :built_in,
#     os_category: :windows_server,
#     name: 'Windows Defender',
#     approved: true,
#     description: 'Windows Server 標準のセキュリティ対策ソフトウェアです。',
#   },
#   {
#     state: :built_in,
#     os_category: :mac,
#     name: 'macOS ランタイムプロテクション',
#     approved: true,
#     description: 'macOS 標準の保護機能です。',
#   },
#   {
#     state: :built_in,
#     os_category: :linux,
#     name: 'ClamAV',
#     approved: true,
#     description: 'ディストリビューションのパッケージとして提供さているClamAVです。',
#   },
#   {
#     state: :built_in,
#     os_category: :bsd,
#     name: 'ClamAV',
#     approved: true,
#     description: 'OSのパッケージとして提供さているClamAVです。',
#   },
# ])

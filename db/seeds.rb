# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

NetworkCategory.count.zero? && NetworkCategory.create([
  {
    name: 'WAN',
    dhcp: false,
    auth: false,
    global: true,
  },
  {
    name: 'DMZ',
    dhcp: false,
    auth: false,
    global: true,
  },
  {
    name: '学内',
    dhcp: false,
    auth: false,
  },
  {
    name: '認証',
    dhcp: true,
    auth: true,
  },
  {
    name: '公衆',
    dhcp: true,
    auth: false,
  }
])

Subnetwork.count.zero? && Subnetwork.create([
  {
    name: 'サーバー',
    network_category: NetworkCategory.find_by(name: '学内'),
    vlan: 101,
  },
  {
    name: 'クライアント',
    network_category: NetworkCategory.find_by(name: '学内'),
    vlan: 102,
  },
  {
    name: 'DMZ',
    network_category: NetworkCategory.find_by(name: 'DMZ'),
    vlan: 200,
  },
  {
    name: 'Wi-Fi',
    network_category: NetworkCategory.find_by(name: '公衆'),
    vlan: 201,
  }
])

IpNetwork.count.zero? && IpNetwork.create([
  {
    subnetwork: Subnetwork.find_by(name: 'サーバー'),
    family: :ipv4,
    address: '192.168.1.0/24',
    gateway: '192.168.1.254',
  },
  {
    subnetwork: Subnetwork.find_by(name: 'クライアント'),
    family: :ipv4,
    address: '192.168.2.0/24',
    gateway: '192.168.2.254',
  }
])

IpPool.count.zero? && IpPool.create([
  {
    ip_network: Subnetwork.find_by(name: 'クライアント').ip_networks.first,
    family: :ipv4,
    config: :dynamic,
    first: '192.168.2.1',
    last: '192.168.2.99',
  },
  {
    ip_network: Subnetwork.find_by(name: 'クライアント').ip_networks.first,
    family: :ipv4,
    config: :reserved,
    first: '192.168.2.100',
    last: '192.168.2.199',
  },
  {
    ip_network: Subnetwork.find_by(name: 'クライアント').ip_networks.first,
    family: :ipv4,
    config: :static,
    first: '192.168.2.200',
    last: '192.168.2.249',
  },
])

OperatingSystem.count.zero? && OperatingSystem.create([
  {
    os_category: :windows_client,
    name: 'Windows 10 Home',
    eol: nil,
  },
  {
    os_category: :windows_client,
    name: 'Windows 10 Pro',
    eol: nil,
  },
  {
    os_category: :windows_client,
    name: 'Windows 10 Enterprise',
    eol: nil,
  },
  {
    os_category: :windows_client,
    name: 'Windows 10 Education',
    eol: nil,
  },
  {
    os_category: :windows_client,
    name: 'Windows 10 S',
    eol: nil,
  },
  {
    os_category: :windows_client,
    name: 'Windows Enterprise 2019 LTSC',
    eol: Time.zone.local(2029, 1, 9),
  },
  {
    os_category: :windows_client,
    name: 'Windows Enterprise 2016 LTSB',
    eol: Time.zone.local(2026, 10, 13),
  },
  {
    os_category: :windows_client,
    name: 'Windows Enterprise 2015 LTSB',
    eol: Time.zone.local(2025, 10, 14),
  },
  {
    os_category: :windows_client,
    name: 'Windows 8.1',
    eol: Time.zone.local(2023, 1, 10),
  },
  {
    os_category: :windows_client,
    name: 'Windows 8',
    eol: Time.zone.local(2016, 1, 12),
    description: 'Windows 8.1へアップデート可能です。',
  },
  {
    os_category: :windows_client,
    name: 'Windows 7',
    eol: Time.zone.local(2020, 1, 14),
  },
  {
    os_category: :windows_client,
    name: 'Windows 7 ESU',
    eol: Time.zone.local(2023, 1, 10),
    description: '有償の「Windows 7 Extended Security Update」を契約しているWindows 7です。',
  },
  {
    os_category: :windows_client,
    name: 'Windows Vista',
    eol: Time.zone.local(2017, 4, 11),
  },
  {
    os_category: :windows_client,
    name: 'Windows XP',
    eol: Time.zone.local(2014, 4, 8),
  },
  {
    os_category: :windows_server,
    name: 'Windows Server SAC',
    eol: nil,
    description: '半期チャンネル(SAC)で提供されるWindows Serverです。',
  },
  {
    os_category: :windows_server,
    name: 'Windows Server 2019',
    eol: Time.zone.local(2029, 1, 9),
  },
  {
    os_category: :windows_server,
    name: 'Windows Server 2016',
    eol: Time.zone.local(2027, 1, 12),
  },
  {
    os_category: :windows_server,
    name: 'Windows Server 2012 R2',
    eol: Time.zone.local(2023, 10, 10),
  },
  {
    os_category: :windows_server,
    name: 'Windows Server 2012',
    eol: Time.zone.local(2023, 10, 10),
  },
  {
    os_category: :windows_server,
    name: 'Windows Server 2008 R2',
    eol: Time.zone.local(2020, 1, 14),
  },
  {
    os_category: :windows_server,
    name: 'Windows Server 2008',
    eol: Time.zone.local(2020, 1, 14),
  },
  {
    os_category: :windows_server,
    name: 'Windows Server 2003 R2',
    eol: Time.zone.local(2015, 7, 14),
  },
  {
    os_category: :windows_server,
    name: 'Windows Server 2003',
    eol: Time.zone.local(2015, 7, 14),
  },
  {
    os_category: :mac,
    name: 'macOS 11.0 Big Sur',
  },
  {
    os_category: :mac,
    name: 'macOS 10.15 Catalina',
  },
  {
    os_category: :mac,
    name: 'macOS 10.14 Mojave',
  },
  {
    os_category: :mac,
    name: 'macOS 10.13 High Sierra',
  },
  {
    os_category: :mac,
    name: 'macOS 10.12 Sierra',
    eol: Time.zone.local(2019, 9, 26),
  },
  {
    os_category: :mac,
    name: 'OS X 10.11 El Capitan',
    eol: Time.zone.local(2018, 7, 9),
  },
  {
    os_category: :mac,
    name: 'OS X 10.10 Yosemite',
    eol: Time.zone.local(2017, 7, 19),
  },
  {
    os_category: :apple,
    name: 'iOS',
  },
  {
    os_category: :apple,
    name: 'iPadOS',
  },
  {
    os_category: :apple,
    name: 'watchOS',
  },
  {
    os_category: :linux,
    name: 'Red Hat Enterprise Linux 8',
    eol: Time.zone.local(2029, 5, 1),
  },
  {
    os_category: :linux,
    name: 'Red Hat Enterprise Linux 7',
    eol: Time.zone.local(2024, 6, 30),
  },
  {
    os_category: :linux,
    name: 'Red Hat Enterprise Linux 6',
    eol: Time.zone.local(2020, 11, 30),
  },
  {
    os_category: :linux,
    name: 'Red Hat Enterprise Linux 6 ELS',
    eol: Time.zone.local(2024, 6, 30),
    description: '追加費用のELS契約をしているRed Hat Etnerprise Linux 6です。',
  },
  {
    os_category: :linux,
    name: 'CentOS 8',
    eol: Time.zone.local(2029, 5, 1),
  },
  {
    os_category: :linux,
    name: 'CentOS 7',
    eol: Time.zone.local(2024, 6, 30),
  },
  {
    os_category: :linux,
    name: 'CentOS 6',
    eol: Time.zone.local(2020, 11, 30),
  },
  {
    os_category: :linux,
    name: 'Ubuntu 20.04 LTS',
    eol: Time.zone.local(2025, 4, 1),
  },
  {
    os_category: :linux,
    name: 'Ubuntu 18.04 LTS',
    eol: Time.zone.local(2023, 4, 1),
  },
  {
    os_category: :linux,
    name: 'Ubuntu 16.04 LTS',
    eol: Time.zone.local(2021, 4, 1),
  },
  {
    os_category: :embedded,
    name: 'Cisco IOS',
    description: 'Cisco製のスイッチ・ルーター等の組み込みOSです。'
  }
])

SecuritySoftware.count.zero? && SecuritySoftware.create([
  {
    state: :built_in,
    os_category: :windows_client,
    name: 'Windows Defender',
    approved: true,
    description: 'Windows 10 標準のセキュリティ対策ソフトウェアです。',
  },
  {
    state: :built_in,
    os_category: :windows_server,
    name: 'Windows Defender',
    approved: true,
    description: 'Windows Server 標準のセキュリティ対策ソフトウェアです。',
  },
  {
    state: :built_in,
    os_category: :mac,
    name: 'macOS ランタイムプロテクション',
    approved: true,
    description: 'macOS 標準の保護機能です。',
  },
  {
    state: :built_in,
    os_category: :linux,
    name: 'ClamAV',
    approved: true,
    description: 'ディストリビューションのパッケージとして提供さているClamAVです。',
  },
  {
    state: :built_in,
    os_category: :bsd,
    name: 'ClamAV',
    approved: true,
    description: 'OSのパッケージとして提供さているClamAVです。',
  },
])

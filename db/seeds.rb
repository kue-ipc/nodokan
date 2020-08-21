# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

NetworkCategory.create([
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

Subnetwork.create([
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

IpNetwork.create([
  {
    subnetwork: Subnetwork.find_by(name: 'サーバー'),
    ip_version: 4,
    address: '192.168.1.0',
    mask: 24,
    gateway: '192.168.1.254',
  },
  {
    subnetwork: Subnetwork.find_by(name: 'クライアント'),
    ip_version: 4,
    address: '192.168.2.0',
    mask: 24,
    gateway: '192.168.2.254',
  }
])

OperatingSystem.create([
  {
    category: :windows,
    name: 'Windows 10 Home',
    eol: nil,
  },
  {
    category: :windows,
    name: 'Windows 10 Pro',
    eol: nil,
  },
  {
    category: :windows,
    name: 'Windows 10 Enterprise',
    eol: nil,
  },
  {
    category: :windows,
    name: 'Windows 10 Education',
    eol: nil,
  },
  {
    category: :windows,
    name: 'Windows 10 S',
    eol: nil,
  },
  {
    category: :windows,
    name: 'Windows Enterprise 2019 LTSC',
    eol: Time.zone.local(2029, 1, 9),
  },
  {
    category: :windows,
    name: 'Windows Enterprise 2016 LTSB',
    eol: Time.zone.local(2026, 10, 13),
  },
  {
    category: :windows,
    name: 'Windows Enterprise 2015 LTSB',
    eol: Time.zone.local(2025, 10, 14),
  },
  {
    category: :windows,
    name: 'Windows 8.1',
    eol: Time.zone.local(2023, 1, 10),
  },
  {
    category: :windows,
    name: 'Windows 8',
    eol: Time.zone.local(2016, 1, 12),
    description: 'Windows 8.1へアップデート可能です。',
  },
  {
    category: :windows,
    name: 'Windows 7',
    eol: Time.zone.local(2020, 1, 14),
  },
  {
    category: :windows,
    name: 'Windows 7 ESU',
    eol: Time.zone.local(2023, 1, 10),
    description: '有償の「Windows 7 Extended Security Update」に参加している場合に限ります。',
  },
  {
    category: :windows,
    name: 'Windows Vista',
    eol: Time.zone.local(2017, 4, 11),
  },
  {
    category: :windows,
    name: 'Windows XP',
    eol: Time.zone.local(2014, 4, 8),
  },
  {
    category: :windows,
    name: 'Windows Server SAC',
    eol: nil,
    description: '半期チャンネル(SAC)で提供されるWindows Serverです。',
  },
  {
    category: :windows,
    name: 'Windows Server 2019',
    eol: Time.zone.local(2029, 1, 9),
  },
  {
    category: :windows,
    name: 'Windows Server 2016',
    eol: Time.zone.local(2027, 1, 12),
  },
  {
    category: :windows,
    name: 'Windows Server 2012 R2',
    eol: Time.zone.local(2015, 10, 10),
  },
  {
    category: :windows,
    name: 'Windows Server 2012',
    eol: Time.zone.local(2023, 10, 10),
  },
  {
    category: :windows,
    name: 'Windows Server 2008 R2',
    eol: Time.zone.local(2020, 1, 14),
  },
  {
    category: :windows,
    name: 'Windows Server 2008',
    eol: Time.zone.local(2020, 1, 14),
  },
  {
    category: :windows,
    name: 'Windows Server 2003 R2',
    eol: Time.zone.local(2015, 7, 14),
  },
  {
    category: :windows,
    name: 'Windows Server 2003',
    eol: Time.zone.local(2015, 7, 14),
  },
  {
    category: :mac,
    name: 'macOS 11.0 Big Sur',
  },
  {
    category: :mac,
    name: 'macOS 10.15 Catalina',
  },
  {
    category: :mac,
    name: 'macOS 10.14 Mojave',
  },
  {
    category: :mac,
    name: 'macOS 10.13 High Sierra',
  },
  {
    category: :mac,
    name: 'macOS 10.12 Sierra',
    eol: Time.zone.local(2019, 9, 26),
  },
  {
    category: :mac,
    name: 'OS X 10.11 El Capitan',
    eol: Time.zone.local(2018, 7, 9),
  },
  {
    category: :mac,
    name: 'OS X 10.10 Yosemite',
    eol: Time.zone.local(2017, 7, 19),
  },
  {
    category: :ios,
    name: 'iOS',
  },
  {
    category: :ios,
    name: 'iPadOS',
  },
  {
    category: :ios,
    name: 'watchOS',
  },
  {
    category: :linux,
    name: 'Red Hat Enterprise Linux 8',
    eol: Time.zone.local(2029, 5, 1),
  },
  {
    category: :linux,
    name: 'Red Hat Enterprise Linux 7',
    eol: Time.zone.local(2024, 6, 30),
  },
  {
    category: :linux,
    name: 'Red Hat Enterprise Linux 6',
    eol: Time.zone.local(2020, 11, 30),
  },
  {
    category: :linux,
    name: 'Red Hat Enterprise Linux 6 ELS',
    eol: Time.zone.local(2024, 6, 30),
    description: '追加費用がかかるELS契約がある場合のみ。',
  },
  {
    category: :linux,
    name: 'CentOS 8',
    eol: Time.zone.local(2029, 5, 1),
  },
  {
    category: :linux,
    name: 'CentOS 7',
    eol: Time.zone.local(2024, 6, 30),
  },
  {
    category: :linux,
    name: 'CentOS 6',
    eol: Time.zone.local(2020, 11, 30),
  },
  {
    category: :linux,
    name: 'Ubuntu 20.04 LTS',
    eol: Time.zone.local(2025, 4, 1),
  },
  {
    category: :linux,
    name: 'Ubuntu 18.04 LTS',
    eol: Time.zone.local(2023, 4, 1),
  },
  {
    category: :linux,
    name: 'Ubuntu 16.04 LTS',
    eol: Time.zone.local(2021, 4, 1),
  }
])

SecuritySoftware.create([
  {
    name: 'Windows Defender (Win10のみ)',
    description: 'Windows 10 標準のセキュリティ対策ソフトウェア',
  },
  {
    name: 'macOS ランタイムプロテクション (macOSのみ)',
    description: 'macOS 標準の保護機能',
  },
  {
    name: 'ClamAV (Linuxディストリビューションパッケージ)',
    description: 'ディストリビューションのパッケージとして提供さているClamAV',
  }
])

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
    global: true
  },
  {
    name: 'DMZ',
    dhcp: false,
    auth: false,
    global: true
  },
  {
    name: '学内',
    dhcp: false,
    auth: false
  },
  {
    name: '認証',
    dhcp: true,
    auth: true
  },
  {
    name: '公衆',
    dhcp: true,
    auth: false
  }
])

Subnetwork.create([
  {
    name: 'サーバー',
    network_category: NetworkCategory.find_by_name('学内'),
    vlan: 101
  },
  {
    name: 'クライアント',
    network_category: NetworkCategory.find_by_name('学内'),
    vlan: 102
  }
])

IpNetwork.create([
  {
    subnetwork: Subnetwork.find_by_name('サーバー'),
    ip_version: 4,
    address: '192.168.1.0',
    mask: 24,
    gateway: '192.168.1.254'
  },
  {
    subnetwork: Subnetwork.find_by_name('クライアント'),
    ip_version: 4,
    address: '192.168.2.0',
    mask: 24,
    gateway: '192.168.2.254'
  }
])

OperatingSystem.create([
  {
    category: :windows,
    name: 'Windows 10',
    eol: nil,
    description: 'Windows 10のすべてのエディションとすべてのバージョン'
  },
  {
    category: :mac,
    name: 'macOS 10.15 Catalina',
    eol: Time.new(2022, 9, 30),
    description: '最新のMacです。'
  }
])

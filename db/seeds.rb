# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

NetworkCategory.create([
  {
    name: 'グローバルネットワーク',
    dhcp: false,
    auth: false,
    global: true
  },
  {
    name: 'DMZネットワーク',
    dhcp: false,
    auth: false,
    global: false
  },
  {
    name: '学内ネットワーク',
    dhcp: false,
    auth: false,
  },
  {
    name: '認証ネットワーク',
    dhcp: true,
    auth: true,
  },
])


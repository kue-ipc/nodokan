# nodekan

## システム要件

* Ruby 3.0 以上
* Node.js 18 以上
* MariaDB 10.5 以上
* Redis 6 以上
* Kea 2.2 以上
* FreeRADIUS 3.0 以上

## 開発環境

```
bundle install
rails yarn:instnall
rails db:setup
rails kea:setup
rails radius:setup
bin/dev
```

## テスト

```
bundle install
rails yarn:instnall
rails db:setup
RAILS_ENV=test rails kea:setup
RAILS_ENV=test radius:setup
rails test
```

# nodekan

## システム要件

* Ruby 3.0
* Node.js 18
* MariaDB 10.3

本番環境ではredisが必要

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

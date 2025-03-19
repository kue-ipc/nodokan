# nodekan

## システム要件

* Ruby >= 3.3
* Node.js >= 20
* MariaDB >= 10.5
* Redis >= 6
* Kea >= 2.6
* FreeRADIUS >= 3.0

## 開発環境

```
bundle install
rails yarn:install
rails db:setup
rails radius:setup
bin/dev
```

## テスト

```
bundle install
rails yarn:install
rails db:setup
RAILS_ENV=test rails radius:setup
rails test
```
## 変更点

- `rails kea:setup`は不要になりました。
- RubyやNode.jsは最新が必須です。

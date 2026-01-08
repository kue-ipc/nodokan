# nodekan

## システム要件

* Ruby >= 3.3
* Node.js >= 20
* MariaDB >= 10.5
* Redis >= 6, <= 7.2 or Valkey >= 8
* Kea >= 2.6
* FreeRADIUS >= 3.0

## 開発環境

```sh
bundle install
rails yarn:install
rails db:setup
rails radius:setup
bin/dev
```

## テスト

```sh
bundle install
rails yarn:install
rails db:setup
RAILS_ENV=test rails radius:setup
rails test
```

## 変更点

- `rails kea:setup`は不要になりました。
- マイナーバージョンアップではredisの互換性を保証しません。ジョブがないときにアップデートしてください。

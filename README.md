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

前のバージョンから標準の動作が変わったところのみ記載しています。機能追加は記載していません。

* 1.0未満のすべて
    * マイナーバージョンアップではredisの互換性を保証しません。ジョブがないときにアップデートしてください。
* 0.7 -> 0.8
    * ネットワークから特定(specific)フラグを削除しました。このフラグは将来の機能で使用を予定していましたが、使用の見込みなないこと、なにか特別な操作が行われるわけではないことから、不要と判断しました。
    * 確認の有効期限はsettingsで変更でき、常に確認日から計算されるようになりました。settingsを変更した場合、既に確認済みの端末の有効期限も変更されます。
* 0.6 -> 0.7
    * `rails kea:setup`は不要になりました。

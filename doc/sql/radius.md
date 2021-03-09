# RADIUSのSQLについて

`attribute`名がRails上では管理できないため、`attr`にしたVIEWを用意する。

```
mysql -u root -p radius < views.sql
```

初期登録
```
rails runner util/setup_radius.rb
```

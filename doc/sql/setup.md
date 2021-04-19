# SQLのセットアップ

## SQLのViewについて

radisuでは、`attribute`名がRails上では管理できないため、`attr`にしたVIEWを用意し、登録する。keaのipv6_reserv

```
mysql -u root radius < radius_views.sql
mysql -u root kea < kea_views.sql
```

初期登録
```
rails runner util/setup_radius.rb
```

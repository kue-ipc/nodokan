# 開発環境メモ

DBのユーザー名とパスワード

ユーザー名: nodokan
パスワード: pass+nodokan42

DBをCREATE/DROPできるように全権限を与える。
```
GRANT ALL ON *.* TO 'nodokan'@'localhost' IDENTIFIED BY 'pass+nodokan42';
```

LDAPのユーザー名とパスワード

ユーザー名: admin
パスワード: pass+admin42

## 既知の問題

* [ ] RADIUSのデータベースに二重登録される場合がある。
* [ ] MACアドレスの二重登録時のエラー画面がおかしい。
* [ ] 管理者で端末ダウンロードに失敗する。
* [ ] 期限切れ端末のカウントがおかしい
* [ ] IPアドレスでソートすると順番がおかしい。

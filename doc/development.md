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

# メモ

## raidusテストメモ

defaultのauthorizeで-ldapをコメントアウトしないとLDAP認証がVLANがなくてもAccess-Acceptになる。

## ユーザの役割

管理者
利用者
ゲスト

ゲストの制限
- 動的以外選べない
- NICは常に一つ
- ユーザー削除時に端末も削除

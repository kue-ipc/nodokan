# メモ

## raidusテストメモ

defaultのauthorizeで-ldapをコメントアウトしないとLDAP認証がVLANがなくてもAccess-Acceptになる。

## ユーザの役割

管理者
利用者
ゲスト

ゲストの制限
- 移譲ができない
- 動的以外選べない
- NICの追加や削除ができない
- ユーザー削除時に端末も削除

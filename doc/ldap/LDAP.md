# LDAP環境

開発およびテスト用のLDAP環境作成のためのメモ

## 389 Directory Server

dscreate from-file ds389.inf

OUは作成済みのためuser_group.ldifのみldapadd

## OpenLDAP (Ubuntu)

初期設定

DNS ドメイン名: example.jp
組織名: exapmle
管理者パスワード: admin_password

ou.ldifとuser_group.ldifをldapadd

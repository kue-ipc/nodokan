# メモ

## Ruby

インストールパッケージ

- rbenv
- build-essential
- libmariadbclient-dev or default-libmysqlclient-dev

rbenvを使用します。

### rbenv

アプリケーション実行ユーザーでのみ実施。

`rbenv init`の実行結果をシェルに設定。

```shell
mkdir -p "$(rbenv root)"/plugins
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
```

upgarde
```
git -C "$(rbenv root)"/plugins/ruby-build pull
```

```
rbenv install 2.7.3
```

```
rbenv local 2.7.3
```

## Node

公式レポジトリを使用するか、snapでstable/latestをいれる。

- nodejs
- yarn

### 公式レポジトリ

https://github.com/nodesource/distributions/blob/master/README.md#debinstall

```
curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install nodejs
```

https://classic.yarnpkg.com/en/docs/install/#debian-stable

```
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install yarn
```

### snap

https://snapcraft.io/node

```
sudo snap install node --classic
```

## MariaDB

- mariadb-server

MariadDBはデフォルトでutf8mb4、utf8mb4_general_ciのため、設定変更は不要です。キーのサイズの変更も不要です。

rootのみ、mysqlでrootになれるため、rootのパスワードは設定しない。

rootはlocalhostのみ、匿名ユーザーもなし、testデータベースもないため、mysql_secure_installationの実行も不要です。

## ISC Kea DHCP

keaは標準のものを使用する。

- kea-admin
- kea-dhcp4-server
- kea-dhcp6-server
- kea-ctrl-agent

本番ではパスワードを適当に変える。

sudo mysql -u root
```
CREATE DATABASE kea;
CREATE USER 'kea'@'localhost' IDENTIFIED BY 'keapass';
GRANT ALL ON kea.* TO 'kea'@'localhost';
```

```
kea-admin db-init mysql -u kea -p keapass -n kea
```

### FreeRADIUS

```
sudo apt install freeradius
sudo apt install freeradius-mysql
sudo apt install freeradius-ldap
```

sudo mysql -u root
```
CREATE DATABASE radius;
```


本番ではパスワードを適当に変える。(ファイルのデフォルトはradpass)

```
cd /etc/freeradius/3.0/mods-config/sql/main/mysql
mysql -u root < setup.sql
mysql -u root radius < schema.sql
```

```
cd /etc/freeradius/3.0/mods-enabled
ln -s ../mods-available/sql .
chown -h freerad:freerad sql
```

```/etc/freeradius/3.0/mods-available/sql
sql {
        dialect = "mysql"
        driver = "rlm_sql_${dialect}"
        server = "localhost"
        port = 3306
        login = "radius"
        password = "radpass"
        radius_db = "radius"
        # 後はデフォルト
}
```

tlsの設定を外さないといけない？

ldapとのダブル認証

ldapは"authentication"でチェックされるようにする？

```
sudo systemctl enable freeradius --now
```
## 開発環境

開発環境はopenldapを入れる

DBは作成権限も付ける

```
GRANT ALL ON *.* TO 'nodokan'@'localhost' IDENTIFIED BY 'pass+nodokan42' WITH GRANT OPTION;
```

## デプロイメント

```
git clone https://github.com/kue-ipc/nodokan
cd nodokan
bundle install --deployment --without development test
RAILS_ENV=production EDITOR=vim rails credentials:edit
RAILS_ENV=production rails db:migrate
RAILS_ENV=production rails db:seed
```

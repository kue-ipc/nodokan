# CentOS 8 での構築方法

この資料は未完成です。

```/etc/sysctl.conf
fs.inotify.max_user_watches = 524288
```

```
sudo sysctl -p
```

### MraiaDB

```
sudo dnf module install mariadb:10.3/server
```

```/etc/my.cnf.d/client.cnf
[client]
default-character-set=utf8mb4
````

```/etc/my.cnf.d/mariadb-server.cnf
[server]
character-set-server=utf8mb4
```

```
sudo systemctl enable mariadb --now
sudo mysql_secure_installation
```

開発環境ではrootのパスワードはpassに設定する。


### FreeRADIUS

```
sudo dnf module install freeradius:3.0/server
sudo dnf install freeradius-mysql
sudo dnf install freeradius-ldap
```

mysql -u root -p
```
CREATE DATABASE radius;
```


本番ではパスワードを適当に変える。(ファイルのデフォルトはradpass)

```
cd /etc/raddb/mods-config/sql/main/mysql
mysql -u root -p < setup.sql
mysql -u root -p radius < schema.sql
```

```
cd /etc/raddb/mods-enabled
ln -s ../mods-available/sql .
chown -h root:radiusd sql
```

```/etc/raddb/mods-available/sql
sql {
        driver = "rlm_sql_mysql"
        dialect = "mysql"
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
sudo systemctl enable radiusd --now
```

### Kea

1.8を使用すること。

```
curl -1sLf \
  'https://dl.cloudsmith.io/public/isc/kea-1-8/cfg/setup/bash.rpm.sh' \
  | sudo -E bash
sudo dnf install isc-kea
```

epelのlog4clpusがコンフリクトするため、

```
sudo dnf update --nobest
```

を付ける必要がある。

本番ではパスワードを適当に変える。

mysql -u root -p
```
CREATE DATABASE kea;
CREATE USER 'kea'@'localhost' IDENTIFIED BY 'keapass';
GRANT ALL ON kea.* TO 'kea'@'localhost';
```

```
kea-admin db-init mysql -u kea -p keapass -n kea
```

### Ruby

sudo dnf module install ruby:2.7/common
sudo dnf install ruby-devel

古いバージョンでは rubygem-bundler も必要になる。

### Node.js

sudo dnf module install nodejs:12/common

### Yarn

新バージョン
```
sudo npm install -g yarn
```

旧バージョン
```
curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
sudo dnf install yarn
```

### 389 Directory Server

sudo dnf module install 389-directory-server:stable/default

```
sudo dscreate from-file ds389.inf
ldapadd -x -h localhost -p 389 -D "cn=admin,dc=example,dc=jp" -w admin_password -f user_group.ldif
```

### nginx

sudo dnf module install nginx:1.16/common

### その他に必要な

sudo dnf install zlib-devel
sudo dnf install mariadb-devel

## インストールなど

bundle install --deployment
bundle exec rails yarn:install
bundle exec rails db:setup

rbenv以外の開発環境では

```
bundle config set path 'vendor/bundle'
bundle install
```

とする。

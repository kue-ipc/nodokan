# CentOS 8 での構築方法

この資料は未完成です。

### MraiaDB

```
sudo dnf module install mariadb:10.3/server
sudo systemctl enable mariadb --now
sudo mysql_secure_installation
```

開発環境ではrootのパスワードはpassに設定する。

```/etc/my.cnf.d/client.cnf
[client]
default-character-set=utf8mb4
````

```/etc/my.cnf.d/mariadb-server.cnf
[server]
character-set-server=utf8mb4
```

### FreeRadius

```
sudo dnf module install freeradius:3.0/server
sudo dnf install freeradius-mysql
sudo dnf install freeradius-ldap
```

/etc/raddb/mods-config/sql/main/mysql

CREATE DATABES 

### Kea

1.6にはCentOS 8のパッケージがない！

```
curl -1sLf \
  'https://dl.cloudsmith.io/public/isc/kea-1-7/cfg/setup/bash.rpm.sh' \
  | sudo -E bash

sudo dnf install isc-kea
```

log4clpusがコンフリクトするため、

```
sudo dnf update --nobest
```

を付ける必要がある。

### Ruby

sudo dnf module install ruby:2.6/common

### Node.js

sudo dnf module install nodejs:12/common

### 389 Directory Server

sudo dnf module install 389-directory-server:stable/default

### nginx

sudo dnf module install nginx:1.16/common


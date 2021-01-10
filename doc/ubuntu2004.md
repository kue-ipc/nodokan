# メモ

```
sudo apt install mariadb-server
```
```
sudo apt install libmariadb-dev
or
sudo apt install default-libmysqlclient-dev
```

## kea
```
curl -1sLf \
  'https://dl.cloudsmith.io/public/isc/kea-1-8/cfg/setup/bash.deb.sh' \
  | sudo -E bash
sudo apt install isc-kea-admin isc-kea-dhcp4-server isc-kea-dhcp6-server isc-kea-ctrl-agent
```

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
sudo systemctl enable radiusd --now
```
## 開発環境

開発環境はopenldapを入れる


DBは作成権限も付ける

```
GRANT ALL ON *.* TO 'nodokan'@'localhost' IDENTIFIED BY 'pass+nodokan42' WITH GRANT OPTION;
```


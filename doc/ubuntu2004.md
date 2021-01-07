# メモ

```
sudo apt install mariadb-server
sudo apt install freeradius
sudo apt install freeradius-mysql
sudo apt install freeradius-ldap
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

## 開発環境

開発環境はopenldapを入れる


DBは作成権限も付ける

```
GRANT ALL ON *.* TO 'nodokan'@'localhost' IDENTIFIED BY 'pass+nodokan42' WITH GRANT OPTION;
```

# CentOS 8 での構築方法

この資料は未完成です。

### MraiaDB

sudo dnf module install mariadb

### FreeRadius

sudo dnf install freeradius
sudo dnf install freeradius-mysql
sudo dnf install freeradius-ldap

### Kea

1.6にはCentOS 8のパッケージがない！

```
curl -1sLf \
  'https://dl.cloudsmith.io/public/isc/kea-1-7/cfg/setup/bash.rpm.sh' \
  | sudo -E bash

dnf install isc-kea
```

# Keaのメモ

## データベース

https://gitlab.isc.org/isc-projects/kea/-/wikis/designs/configuration-in-db-design

https://gitlab.isc.org/isc-projects/kea/-/wikis/designs/host-reservation


isc-kea-ctrl-agent.service
isc-kea-dhcp4-server.service
isc-kea-dhcp6-server.service

kea-admin db-init mysql -u kea -p keapass -n kea


kea-admin db-upgrade mysql -u kea -p keapass -n kea

sudo apt install kea-commn

kea-shell は http_proxy の設定の影響を受けるので注意

```
{
    "command": "foo",
    "service": [ "dhcp4" ]
    "arguments": {
        "param1": "value1",
        "param2": "value2",
        ...
    }
}
```

プールのDBを更新するにはauditを無効にする
connection.execute('SET @disable_audit = 1;')
またはauditを設定する必要がある。

## スキーマバージョンについて

- epel kea-2.2.0 14.0
- cloudsmith kea-2.2.1 14.0
- cloudsmith kea-2.4.1 19.0
- cloudsmith kea-2.6.0 22.0
- cloudsmith kea-2.6.1 22.1

## DHCPオプションについて


| DNS | domain-name-servers | dns-servers | ip-address | true |
| ドメイン | domain-name |  | fqdn | false |
| サーチ | domain-search | domain-search | fqdn | true |
<!-- | ブートファイル |    | bootfile-url|                         url -->

ntp
tftp host, boot
next-server



DHCP4

DHCP6





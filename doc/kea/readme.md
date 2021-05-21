# Keaのメモ

https://gitlab.isc.org/isc-projects/kea/-/wikis/designs/configuration-in-db-design


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

auditを無効にしないといけない。
connection.execute('SET @disable_audit = 1;')

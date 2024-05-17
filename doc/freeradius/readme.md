# FreeRADIUS 設定

バージョン 3 以上

デフォルトではUser-PasswordまたはChap-PasswordがDBのradostauthにそのまま入るため、サイトの設定でpost-authに次を追加すること

```unlang
post-auth {
	# User-Password is replaced Tunnel-Private-Group-Id for sql log.
	update request {
		User-Password := "%{reply:Tunnel-Private-Group-Id}"
	}
    ...
```

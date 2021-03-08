# raidusテストメモ


```
(0) Received Access-Request Id 88 from 127.0.0.1:51778 to 127.0.0.1:1812 length 74
(0)   User-Name = "test"
(0)   User-Password = "aaa"
(0)   NAS-IP-Address = 127.0.1.1
(0)   NAS-Port = 0
(0)   Message-Authenticator = 0xd62870d6f9af99a0d50ec7de26344a62
(0) # Executing section authorize from file /etc/freeradius/3.0/sites-enabled/default
(0)   authorize {
(0)     policy filter_username {
(0)       if (&User-Name) {
(0)       if (&User-Name)  -> TRUE
(0)       if (&User-Name)  {
(0)         if (&User-Name =~ / /) {
(0)         if (&User-Name =~ / /)  -> FALSE
(0)         if (&User-Name =~ /@[^@]*@/ ) {
(0)         if (&User-Name =~ /@[^@]*@/ )  -> FALSE
(0)         if (&User-Name =~ /\.\./ ) {
(0)         if (&User-Name =~ /\.\./ )  -> FALSE
(0)         if ((&User-Name =~ /@/) && (&User-Name !~ /@(.+)\.(.+)$/))  {
(0)         if ((&User-Name =~ /@/) && (&User-Name !~ /@(.+)\.(.+)$/))   -> FALSE
(0)         if (&User-Name =~ /\.$/)  {
(0)         if (&User-Name =~ /\.$/)   -> FALSE
(0)         if (&User-Name =~ /@\./)  {
(0)         if (&User-Name =~ /@\./)   -> FALSE
(0)       } # if (&User-Name)  = notfound
(0)     } # policy filter_username = notfound
(0)     [preprocess] = ok
(0)     [chap] = noop
(0)     [mschap] = noop
(0)     [digest] = noop
(0) suffix: Checking for suffix after "@"
(0) suffix: No '@' in User-Name = "test", looking up realm NULL
(0) suffix: No such realm "NULL"
(0)     [suffix] = noop
(0) eap: No EAP-Message, not doing EAP
(0)     [eap] = noop
(0)     [files] = noop
(0) sql: EXPAND %{User-Name}
(0) sql:    --> test
(0) sql: SQL-User-Name set to 'test'
rlm_sql (sql): Reserved connection (0)
(0) sql: EXPAND SELECT id, username, attribute, value, op FROM radcheck WHERE username = '%{SQL-User-Name}' ORDER BY id
(0) sql:    --> SELECT id, username, attribute, value, op FROM radcheck WHERE username = 'test' ORDER BY id
(0) sql: Executing select query: SELECT id, username, attribute, value, op FROM radcheck WHERE username = 'test' ORDER BY id
(0) sql: User found in radcheck table
(0) sql: Conditional check items matched, merging assignment check items
(0) sql:   Cleartext-Password := "aaa"
(0) sql: EXPAND SELECT id, username, attribute, value, op FROM radreply WHERE username = '%{SQL-User-Name}' ORDER BY id
(0) sql:    --> SELECT id, username, attribute, value, op FROM radreply WHERE username = 'test' ORDER BY id
(0) sql: Executing select query: SELECT id, username, attribute, value, op FROM radreply WHERE username = 'test' ORDER BY id
(0) sql: User found in radreply table, merging reply items
(0) sql:   Tunnel-Private-Group-Id := "101"
rlm_sql (sql): Reserved connection (1)
rlm_sql (sql): Released connection (1)
Need 6 more connections to reach 10 spares
rlm_sql (sql): Opening additional connection (5), 1 of 27 pending slots used
rlm_sql_mysql: Starting connect to MySQL server
rlm_sql_mysql: Connected to database 'radius' on Localhost via UNIX socket, server version 5.5.5-10.3.25-MariaDB-0ubuntu0.20.04.1, protocol version 10
(0) sql: EXPAND SELECT groupname FROM radusergroup WHERE username = '%{SQL-User-Name}' ORDER BY priority
(0) sql:    --> SELECT groupname FROM radusergroup WHERE username = 'test' ORDER BY priority
(0) sql: Executing select query: SELECT groupname FROM radusergroup WHERE username = 'test' ORDER BY priority
(0) sql: User found in the group table
(0) sql: EXPAND SELECT id, groupname, attribute, Value, op FROM radgroupcheck WHERE groupname = '%{SQL-Group}' ORDER BY id
(0) sql:    --> SELECT id, groupname, attribute, Value, op FROM radgroupcheck WHERE groupname = 'hoge' ORDER BY id
(0) sql: Executing select query: SELECT id, groupname, attribute, Value, op FROM radgroupcheck WHERE groupname = 'hoge' ORDER BY id
(0) sql: Group "hoge": Conditional check items matched
(0) sql: Group "hoge": Merging assignment check items
(0) sql: EXPAND SELECT id, groupname, attribute, value, op FROM radgroupreply WHERE groupname = '%{SQL-Group}' ORDER BY id
(0) sql:    --> SELECT id, groupname, attribute, value, op FROM radgroupreply WHERE groupname = 'hoge' ORDER BY id
(0) sql: Executing select query: SELECT id, groupname, attribute, value, op FROM radgroupreply WHERE groupname = 'hoge' ORDER BY id
(0) sql: Group "hoge": Merging reply items
(0) sql:   Tunnel-Type := VLAN
(0) sql:   Tunnel-Medium-Type := IEEE-802
rlm_sql (sql): Released connection (0)
(0)     [sql] = ok
rlm_ldap (ldap): Reserved connection (0)
(0) ldap: EXPAND (uid=%{%{Stripped-User-Name}:-%{User-Name}})
(0) ldap:    --> (uid=test)
(0) ldap: Performing search in "ou=people,dc=example,dc=jp" with filter "(uid=test)", scope "sub"
(0) ldap: Waiting for search result...
(0) ldap: Search returned no results
rlm_ldap (ldap): Released connection (0)
Need 5 more connections to reach 10 spares
rlm_ldap (ldap): Opening additional connection (5), 1 of 27 pending slots used
rlm_ldap (ldap): Connecting to ldap://localhost:389
rlm_ldap (ldap): Waiting for bind result...
rlm_ldap (ldap): Bind successful
(0)     [ldap] = notfound
(0)     [expiration] = noop
(0)     [logintime] = noop
(0)     [pap] = updated
(0)   } # authorize = updated
(0) Found Auth-Type = PAP
(0) # Executing group from file /etc/freeradius/3.0/sites-enabled/default
(0)   Auth-Type PAP {
(0) pap: Login attempt with password
(0) pap: Comparing with "known good" Cleartext-Password
(0) pap: User authenticated successfully
(0)     [pap] = ok
(0)   } # Auth-Type PAP = ok
(0) # Executing section post-auth from file /etc/freeradius/3.0/sites-enabled/default
(0)   post-auth {
(0)     if (session-state:User-Name && reply:User-Name && request:User-Name && (reply:User-Name == request:User-Name)) {
(0)     if (session-state:User-Name && reply:User-Name && request:User-Name && (reply:User-Name == request:User-Name))  -> FALSE
(0)     update {
(0)       No attributes updated for RHS &session-state:
(0)     } # update = noop
(0) sql: EXPAND .query
(0) sql:    --> .query
(0) sql: Using query template 'query'
rlm_sql (sql): Reserved connection (2)
(0) sql: EXPAND %{User-Name}
(0) sql:    --> test
(0) sql: SQL-User-Name set to 'test'
(0) sql: EXPAND INSERT INTO radpostauth (username, pass, reply, authdate) VALUES ( '%{SQL-User-Name}', '%{%{User-Password}:-%{Chap-Password}}', '%{reply:Packet-Type}', '%S')
(0) sql:    --> INSERT INTO radpostauth (username, pass, reply, authdate) VALUES ( 'test', 'aaa', 'Access-Accept', '2021-03-08 17:05:24')
(0) sql: EXPAND /var/log/freeradius/sqllog.sql
(0) sql:    --> /var/log/freeradius/sqllog.sql
(0) sql: Executing query: INSERT INTO radpostauth (username, pass, reply, authdate) VALUES ( 'test', 'aaa', 'Access-Accept', '2021-03-08 17:05:24')
(0) sql: SQL query returned: success
(0) sql: 1 record(s) updated
rlm_sql (sql): Released connection (2)
(0)     [sql] = ok
(0)     [exec] = noop
(0)     policy remove_reply_message_if_eap {
(0)       if (&reply:EAP-Message && &reply:Reply-Message) {
(0)       if (&reply:EAP-Message && &reply:Reply-Message)  -> FALSE
(0)       else {
(0)         [noop] = noop
(0)       } # else = noop
(0)     } # policy remove_reply_message_if_eap = noop
(0)   } # post-auth = ok
(0) Login OK: [test] (from client localhost port 0)
(0) Sent Access-Accept Id 88 from 127.0.0.1:1812 to 127.0.0.1:51778 length 0
(0)   Tunnel-Private-Group-Id = "101"
(0)   Tunnel-Type = VLAN
(0)   Tunnel-Medium-Type = IEEE-802
(0) Finished request
Waking up in 4.9 seconds.
(0) Cleaning up request packet ID 88 with timestamp +8
Ready to process requests
```


```
(1) Received Access-Request Id 74 from 127.0.0.1:48438 to 127.0.0.1:1812 length 76
(1)   User-Name = "user01"
(1)   User-Password = "pass0001"
(1)   NAS-IP-Address = 127.0.1.1
(1)   NAS-Port = 0
(1)   Message-Authenticator = 0xf8ab1cd6bc5a25d75e1823b359712a30
(1) # Executing section authorize from file /etc/freeradius/3.0/sites-enabled/default
(1)   authorize {
(1)     policy filter_username {
(1)       if (&User-Name) {
(1)       if (&User-Name)  -> TRUE
(1)       if (&User-Name)  {
(1)         if (&User-Name =~ / /) {
(1)         if (&User-Name =~ / /)  -> FALSE
(1)         if (&User-Name =~ /@[^@]*@/ ) {
(1)         if (&User-Name =~ /@[^@]*@/ )  -> FALSE
(1)         if (&User-Name =~ /\.\./ ) {
(1)         if (&User-Name =~ /\.\./ )  -> FALSE
(1)         if ((&User-Name =~ /@/) && (&User-Name !~ /@(.+)\.(.+)$/))  {
(1)         if ((&User-Name =~ /@/) && (&User-Name !~ /@(.+)\.(.+)$/))   -> FALSE
(1)         if (&User-Name =~ /\.$/)  {
(1)         if (&User-Name =~ /\.$/)   -> FALSE
(1)         if (&User-Name =~ /@\./)  {
(1)         if (&User-Name =~ /@\./)   -> FALSE
(1)       } # if (&User-Name)  = notfound
(1)     } # policy filter_username = notfound
(1)     [preprocess] = ok
(1)     [chap] = noop
(1)     [mschap] = noop
(1)     [digest] = noop
(1) suffix: Checking for suffix after "@"
(1) suffix: No '@' in User-Name = "user01", looking up realm NULL
(1) suffix: No such realm "NULL"
(1)     [suffix] = noop
(1) eap: No EAP-Message, not doing EAP
(1)     [eap] = noop
(1)     [files] = noop
(1) sql: EXPAND %{User-Name}
(1) sql:    --> user01
(1) sql: SQL-User-Name set to 'user01'
rlm_sql (sql): Closing connection (3): Hit idle_timeout, was idle for 73 seconds
rlm_sql_mysql: Socket destructor called, closing socket
rlm_sql (sql): Closing connection (4): Hit idle_timeout, was idle for 73 seconds
rlm_sql_mysql: Socket destructor called, closing socket
rlm_sql (sql): Closing connection (0): Hit idle_timeout, was idle for 65 seconds
rlm_sql_mysql: Socket destructor called, closing socket
rlm_sql (sql): Closing connection (1): Hit idle_timeout, was idle for 65 seconds
rlm_sql (sql): You probably need to lower "min"
rlm_sql_mysql: Socket destructor called, closing socket
rlm_sql (sql): Closing connection (5): Hit idle_timeout, was idle for 65 seconds
rlm_sql (sql): You probably need to lower "min"
rlm_sql_mysql: Socket destructor called, closing socket
rlm_sql (sql): Closing connection (2): Hit idle_timeout, was idle for 65 seconds
rlm_sql (sql): You probably need to lower "min"
rlm_sql_mysql: Socket destructor called, closing socket
rlm_sql (sql): 0 of 0 connections in use.  You  may need to increase "spare"
rlm_sql (sql): Opening additional connection (6), 1 of 32 pending slots used
rlm_sql_mysql: Starting connect to MySQL server
rlm_sql_mysql: Connected to database 'radius' on Localhost via UNIX socket, server version 5.5.5-10.3.25-MariaDB-0ubuntu0.20.04.1, protocol version 10
rlm_sql (sql): Reserved connection (6)
(1) sql: EXPAND SELECT id, username, attribute, value, op FROM radcheck WHERE username = '%{SQL-User-Name}' ORDER BY id
(1) sql:    --> SELECT id, username, attribute, value, op FROM radcheck WHERE username = 'user01' ORDER BY id
(1) sql: Executing select query: SELECT id, username, attribute, value, op FROM radcheck WHERE username = 'user01' ORDER BY id
(1) sql: WARNING: User not found in radcheck table.
rlm_sql (sql): 1 of 1 connections in use.  You  may need to increase "spare"
rlm_sql (sql): Opening additional connection (7), 1 of 31 pending slots used
rlm_sql_mysql: Starting connect to MySQL server
rlm_sql_mysql: Connected to database 'radius' on Localhost via UNIX socket, server version 5.5.5-10.3.25-MariaDB-0ubuntu0.20.04.1, protocol version 10
rlm_sql (sql): Reserved connection (7)
rlm_sql (sql): Released connection (7)
Need 1 more connections to reach min connections (3)
rlm_sql (sql): Opening additional connection (8), 1 of 30 pending slots used
rlm_sql_mysql: Starting connect to MySQL server
rlm_sql_mysql: Connected to database 'radius' on Localhost via UNIX socket, server version 5.5.5-10.3.25-MariaDB-0ubuntu0.20.04.1, protocol version 10
(1) sql: EXPAND SELECT groupname FROM radusergroup WHERE username = '%{SQL-User-Name}' ORDER BY priority
(1) sql:    --> SELECT groupname FROM radusergroup WHERE username = 'user01' ORDER BY priority
(1) sql: Executing select query: SELECT groupname FROM radusergroup WHERE username = 'user01' ORDER BY priority
(1) sql: User found in the group table
(1) sql: EXPAND SELECT id, groupname, attribute, Value, op FROM radgroupcheck WHERE groupname = '%{SQL-Group}' ORDER BY id
(1) sql:    --> SELECT id, groupname, attribute, Value, op FROM radgroupcheck WHERE groupname = 'user' ORDER BY id
(1) sql: Executing select query: SELECT id, groupname, attribute, Value, op FROM radgroupcheck WHERE groupname = 'user' ORDER BY id
(1) sql: Group "user": Conditional check items matched
(1) sql: Group "user": Merging assignment check items
(1) sql: EXPAND SELECT id, groupname, attribute, value, op FROM radgroupreply WHERE groupname = '%{SQL-Group}' ORDER BY id
(1) sql:    --> SELECT id, groupname, attribute, value, op FROM radgroupreply WHERE groupname = 'user' ORDER BY id
(1) sql: Executing select query: SELECT id, groupname, attribute, value, op FROM radgroupreply WHERE groupname = 'user' ORDER BY id
(1) sql: Group "user": Merging reply items
(1) sql:   Tunnel-Type := VLAN
(1) sql:   Tunnel-Medium-Type := IEEE-802
rlm_sql (sql): Released connection (6)
(1)     [sql] = ok
rlm_ldap (ldap): Closing connection (1): Hit idle_timeout, was idle for 73 seconds
rlm_ldap (ldap): Closing connection (2): Hit idle_timeout, was idle for 73 seconds
rlm_ldap (ldap): Closing connection (3): Hit idle_timeout, was idle for 73 seconds
rlm_ldap (ldap): Closing connection (4): Hit idle_timeout, was idle for 73 seconds
rlm_ldap (ldap): You probably need to lower "min"
rlm_ldap (ldap): Closing connection (0): Hit idle_timeout, was idle for 65 seconds
rlm_ldap (ldap): You probably need to lower "min"
rlm_ldap (ldap): Closing connection (5): Hit idle_timeout, was idle for 65 seconds
rlm_ldap (ldap): You probably need to lower "min"
rlm_ldap (ldap): 0 of 0 connections in use.  You  may need to increase "spare"
rlm_ldap (ldap): Opening additional connection (6), 1 of 32 pending slots used
rlm_ldap (ldap): Connecting to ldap://localhost:389
rlm_ldap (ldap): Waiting for bind result...
rlm_ldap (ldap): Bind successful
rlm_ldap (ldap): Reserved connection (6)
(1) ldap: EXPAND (uid=%{%{Stripped-User-Name}:-%{User-Name}})
(1) ldap:    --> (uid=user01)
(1) ldap: Performing search in "ou=people,dc=example,dc=jp" with filter "(uid=user01)", scope "sub"
(1) ldap: Waiting for search result...
(1) ldap: User object found at DN "uid=user01,ou=people,dc=example,dc=jp"
(1) ldap: Processing user attributes
(1) ldap: control:Password-With-Header += 'pass0001'
rlm_ldap (ldap): Released connection (6)
Need 2 more connections to reach min connections (3)
rlm_ldap (ldap): Opening additional connection (7), 1 of 31 pending slots used
rlm_ldap (ldap): Connecting to ldap://localhost:389
rlm_ldap (ldap): Waiting for bind result...
rlm_ldap (ldap): Bind successful
(1)     [ldap] = updated
(1)     [expiration] = noop
(1)     [logintime] = noop
(1) pap: No {...} in Password-With-Header, re-writing to Cleartext-Password
(1) pap: Removing &control:Password-With-Header
(1)     [pap] = updated
(1)   } # authorize = updated
(1) Found Auth-Type = PAP
(1) # Executing group from file /etc/freeradius/3.0/sites-enabled/default
(1)   Auth-Type PAP {
(1) pap: Login attempt with password
(1) pap: Comparing with "known good" Cleartext-Password
(1) pap: User authenticated successfully
(1)     [pap] = ok
(1)   } # Auth-Type PAP = ok
(1) # Executing section post-auth from file /etc/freeradius/3.0/sites-enabled/default
(1)   post-auth {
(1)     if (session-state:User-Name && reply:User-Name && request:User-Name && (reply:User-Name == request:User-Name)) {
(1)     if (session-state:User-Name && reply:User-Name && request:User-Name && (reply:User-Name == request:User-Name))  -> FALSE
(1)     update {
(1)       No attributes updated for RHS &session-state:
(1)     } # update = noop
(1) sql: EXPAND .query
(1) sql:    --> .query
(1) sql: Using query template 'query'
rlm_sql (sql): Reserved connection (6)
(1) sql: EXPAND %{User-Name}
(1) sql:    --> user01
(1) sql: SQL-User-Name set to 'user01'
(1) sql: EXPAND INSERT INTO radpostauth (username, pass, reply, authdate) VALUES ( '%{SQL-User-Name}', '%{%{User-Password}:-%{Chap-Password}}', '%{reply:Packet-Type}', '%S')
(1) sql:    --> INSERT INTO radpostauth (username, pass, reply, authdate) VALUES ( 'user01', 'pass0001', 'Access-Accept', '2021-03-08 17:06:29')
(1) sql: EXPAND /var/log/freeradius/sqllog.sql
(1) sql:    --> /var/log/freeradius/sqllog.sql
(1) sql: Executing query: INSERT INTO radpostauth (username, pass, reply, authdate) VALUES ( 'user01', 'pass0001', 'Access-Accept', '2021-03-08 17:06:29')
(1) sql: SQL query returned: success
(1) sql: 1 record(s) updated
rlm_sql (sql): Released connection (6)
(1)     [sql] = ok
(1)     [exec] = noop
(1)     policy remove_reply_message_if_eap {
(1)       if (&reply:EAP-Message && &reply:Reply-Message) {
(1)       if (&reply:EAP-Message && &reply:Reply-Message)  -> FALSE
(1)       else {
(1)         [noop] = noop
(1)       } # else = noop
(1)     } # policy remove_reply_message_if_eap = noop
(1)   } # post-auth = ok
(1) Login OK: [user01] (from client localhost port 0)
(1) Sent Access-Accept Id 74 from 127.0.0.1:1812 to 127.0.0.1:48438 length 0
(1)   Tunnel-Type = VLAN
(1)   Tunnel-Medium-Type = IEEE-802
(1) Finished request
Waking up in 4.9 seconds.
(1) Cleaning up request packet ID 74 with timestamp +73
Ready to process requests
```

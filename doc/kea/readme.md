
isc-kea-ctrl-agent.service
isc-kea-dhcp4-server.service
isc-kea-dhcp6-server.service

kea-admin db-init mysql -u kea -p keapass -n kea


kea-admin db-upgrade mysql -u kea -p keapass -n kea

sudo apt install kea-commn

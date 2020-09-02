# メモ

開発環境のみ

sudo apt install 389-ds
sudo apt install python3-lib389

sudo apt install freeradius
sudo apt install freeradius-mysql

あとはmariadbとか

curl -1sLf \
  'https://dl.cloudsmith.io/public/isc/kea-1-8/cfg/setup/bash.deb.sh' \
  | sudo -E bash
sudo apt install isc-kea-admin isc-kea-dhcp4-server isc-kea-dhcp6-server isc-kea-ctrl-agent

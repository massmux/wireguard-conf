#!/bin/bash


echo "installing software"
apt-get update
apt-get -y install wireguard

mkdir $WORKDIR
cd $WORKDIR

echo "generating private/public key pair for this server"
umask 077
wg genkey | tee privatekey | wg pubkey > publickey

clipub=`cat publickey`
clipriv=`cat privatekey`

CFG_HOSTNAME_FQDN=$(hostname -f); # hostname -A
IP_ADDRESS=( $(hostname -I) );
RE='^2([0-4][0-9]|5[0-5])|1?[0-9][0-9]{1,2}(\.(2([0-4][0-9]|5[0-5])|1?[0-9]{1,2})){3}$'
IPv4_ADDRESS=( $(for i in ${IP_ADDRESS[*]}; do [[ "$i" =~ $RE ]] && echo "$i"; done) )
RE='^[[:xdigit:]]{1,4}(:[[:xdigit:]]{1,4}){7}$'
IPv6_ADDRESS=( $(for i in ${IP_ADDRESS[*]}; do [[ "$i" =~ $RE ]] && echo "$i"; done) )

echo "writing wg0.conf file"
tee wg0.conf <<EOF
[Interface]
PrivateKey = $clipriv
Address = 192.168.6.2/24

[Peer]
PublicKey = $SRVPUB
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = $SRVIPPORT
PersistentKeepalive = 15

[Peer]
## Desktop/client VPN public key ##
PublicKey = $clipub
EOF

echo "enabling the client"
systemctl enable wg-quick@wg0.service

#echo "restarting the client"
#systemctl restart wg-quick@wg0.service

echo "peer public key is: $clipub"
echo "insert the client public key to wg0.conf on the server"
echo "and then restart the server: systemctl restart wg-quick@wg0.service"


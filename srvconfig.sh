#!/bin/bash

#WORKDIR="/tmp"
WORKDIR="/etc/wireguard"

sudo apt-get update
sudo apt-get -y install wireguard

cd $WORKDIR

# creating public/private key pair
umask 077
wg genkey | tee privatekey | wg pubkey > publickey

srvpub=`cat publickey`
srvpriv=`cat privatekey`

CFG_HOSTNAME_FQDN=$(hostname -f); # hostname -A
IP_ADDRESS=( $(hostname -I) );
RE='^2([0-4][0-9]|5[0-5])|1?[0-9][0-9]{1,2}(\.(2([0-4][0-9]|5[0-5])|1?[0-9]{1,2})){3}$'
IPv4_ADDRESS=( $(for i in ${IP_ADDRESS[*]}; do [[ "$i" =~ $RE ]] && echo "$i"; done) )
RE='^[[:xdigit:]]{1,4}(:[[:xdigit:]]{1,4}){7}$'
IPv6_ADDRESS=( $(for i in ${IP_ADDRESS[*]}; do [[ "$i" =~ $RE ]] && echo "$i"; done) )

echo "setting ip forward"
tee /etc/sysctl.d/10-wireguard.conf <<EOF
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
EOF

echo "activating ip forward"
sysctl -p /etc/sysctl.d/10-wireguard.conf

echo "creating helpers"
mkdir $WORKDIR/helper

tee $WORKDIR/helper/add-nat-routing.sh <<EOF
#!/bin/bash
IPT="/sbin/iptables"
IPT6="/sbin/ip6tables"

IN_FACE="eth0"                   # NIC connected to the internet
WG_FACE="wg0"                    # WG NIC
SUB_NET="192.168.6.0/24"            # WG IPv4 sub/net aka CIDR
WG_PORT="41194"                  # WG udp port
SUB_NET_6="fd42:42:42:42::/112"  # WG IPv6 sub/net

## IPv4 ##
$IPT -t nat -I POSTROUTING 1 -s $SUB_NET -o $IN_FACE -j MASQUERADE
$IPT -I INPUT 1 -i $WG_FACE -j ACCEPT
$IPT -I FORWARD 1 -i $IN_FACE -o $WG_FACE -j ACCEPT
$IPT -I FORWARD 1 -i $WG_FACE -o $IN_FACE -j ACCEPT
$IPT -I INPUT 1 -i $IN_FACE -p udp --dport $WG_PORT -j ACCEPT

## IPv6
$IPT6 -t nat -I POSTROUTING 1 -s $SUB_NET_6 -o $IN_FACE -j MASQUERADE
$IPT6 -I INPUT 1 -i $WG_FACE -j ACCEPT
$IPT6 -I FORWARD 1 -i $IN_FACE -o $WG_FACE -j ACCEPT
$IPT6 -I FORWARD 1 -i $WG_FACE -o $IN_FACE -j ACCEPT
EOF

tee $WORKDIR/helper/remove-nat-routing.sh <<EOF
#!/bin/bash
IPT="/sbin/iptables"
IPT6="/sbin/ip6tables"          
 
IN_FACE="eth0"                   # NIC connected to the internet
WG_FACE="wg0"                    # WG NIC 
SUB_NET="192.168.6.0/24"            # WG IPv4 sub/net aka CIDR
WG_PORT="41194"                  # WG udp port
SUB_NET_6="fd42:42:42:42::/112"  # WG IPv6 sub/net
 
# IPv4 rules #
$IPT -t nat -D POSTROUTING -s $SUB_NET -o $IN_FACE -j MASQUERADE
$IPT -D INPUT -i $WG_FACE -j ACCEPT
$IPT -D FORWARD -i $IN_FACE -o $WG_FACE -j ACCEPT
$IPT -D FORWARD -i $WG_FACE -o $IN_FACE -j ACCEPT
$IPT -D INPUT -i $IN_FACE -p udp --dport $WG_PORT -j ACCEPT
 
# IPv6 rules
$IPT6 -t nat -D POSTROUTING -s $SUB_NET_6 -o $IN_FACE -j MASQUERADE
$IPT6 -D INPUT -i $WG_FACE -j ACCEPT
$IPT6 -D FORWARD -i $IN_FACE -o $WG_FACE -j ACCEPT
$IPT6 -D FORWARD -i $WG_FACE -o $IN_FACE -j ACCEPT
EOF

echo "making helpers executable"
chmod -v +x $WORKDIR/helper/*.sh

echo "writing wg0.conf file"
tee wg0.conf <<EOF
[Interface]
Address = 192.168.6.1/24
ListenPort = 41194
PrivateKey = $srvpriv
PostUp = $WORKDIR/helper/add-nat-routing.sh
PostDown = $WORKDIR/helper/remove-nat-routing.sh

[Peer]
# must be changed with peer1 public key
PublicKey = PEER1PUB
AllowedIPs = 192.168.6.2/32
EOF


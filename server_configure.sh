#!/bin/bash

#   Copyright (C) 2019-2020 Denali Sàrl www.denali.swiss, Massimo Musumeci, @massmux
#
#   Installing script for wireguard on linux
#
#   It is subject to the license terms in the LICENSE file found in the top-level
#   directory of this distribution.
#
#   No part of this software, including this file, may be copied, modified,
#   propagated, or distributed except according to the terms contained in the
#   LICENSE file.
#   The above copyright notice and this permission notice shall be included in
#   all copies or substantial portions of the Software.
#
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
#   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER




echo "installing software"

apt-get update
apt-get -y install wireguard

if [ ! -d "$WORKDIR" ]; then
        mkdir $WORKDIR
fi

cd $WORKDIR
echo "generating private/public key pair for this server"
umask 077
wg genkey | tee privatekey | wg pubkey > publickey

srvpub=`cat publickey`
srvpriv=`cat privatekey`

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

IN_FACE="$IFACE"                   # NIC connected to the internet
WG_FACE="wg0"                    # WG NIC
SUB_NET="$WGSUBNET"            # WG IPv4 sub/net aka CIDR
WG_PORT="$IPORT"                  # WG udp port
SUB_NET_6="$WGSUBNET6"  # WG IPv6 sub/net

## IPv4 ##
\$IPT -t nat -I POSTROUTING 1 -s \$SUB_NET -o \$IN_FACE -j MASQUERADE
\$IPT -I INPUT 1 -i \$WG_FACE -j ACCEPT
\$IPT -I FORWARD 1 -i \$IN_FACE -o \$WG_FACE -j ACCEPT
\$IPT -I FORWARD 1 -i \$WG_FACE -o \$IN_FACE -j ACCEPT
\$IPT -I INPUT 1 -i \$IN_FACE -p udp --dport \$WG_PORT -j ACCEPT
## IPv6
\$IPT6 -t nat -I POSTROUTING 1 -s \$SUB_NET_6 -o \$IN_FACE -j MASQUERADE
\$IPT6 -I INPUT 1 -i \$WG_FACE -j ACCEPT
\$IPT6 -I FORWARD 1 -i \$IN_FACE -o \$WG_FACE -j ACCEPT
\$IPT6 -I FORWARD 1 -i \$WG_FACE -o \$IN_FACE -j ACCEPT
EOF

tee $WORKDIR/helper/remove-nat-routing.sh <<EOF
#!/bin/bash
IPT="/sbin/iptables"
IPT6="/sbin/ip6tables"          
 
IN_FACE="$IFACE"                   # NIC connected to the internet
WG_FACE="wg0"                    # WG NIC 
SUB_NET="$WGSUBNET"            # WG IPv4 sub/net aka CIDR
WG_PORT="$IPORT"                  # WG udp port
SUB_NET_6="$WGSUBNET6"  # WG IPv6 sub/net
 
# IPv4 rules #
\$IPT -t nat -D POSTROUTING -s \$SUB_NET -o \$IN_FACE -j MASQUERADE
\$IPT -D INPUT -i \$WG_FACE -j ACCEPT
\$IPT -D FORWARD -i \$IN_FACE -o \$WG_FACE -j ACCEPT
\$IPT -D FORWARD -i \$WG_FACE -o \$IN_FACE -j ACCEPT
\$IPT -D INPUT -i \$IN_FACE -p udp --dport \$WG_PORT -j ACCEPT
# IPv6 rules
\$IPT6 -t nat -D POSTROUTING -s \$SUB_NET_6 -o \$IN_FACE -j MASQUERADE
\$IPT6 -D INPUT -i \$WG_FACE -j ACCEPT
\$IPT6 -D FORWARD -i \$IN_FACE -o \$WG_FACE -j ACCEPT
\$IPT6 -D FORWARD -i \$WG_FACE -o \$IN_FACE -j ACCEPT
EOF

echo "making helpers executable"
chmod -v +x $WORKDIR/helper/*.sh

echo "writing wg0.conf file"
tee wg0.conf <<EOF
[Interface]
Address = $srvprivip
ListenPort = $IPORT
PrivateKey = $srvpriv
PostUp = $WORKDIR/helper/add-nat-routing.sh
PostDown = $WORKDIR/helper/remove-nat-routing.sh

EOF

echo "enabling the server"
systemctl enable wg-quick@wg0.service

echo "==== Server public key ===="
echo "Server public key is: $srvpub"


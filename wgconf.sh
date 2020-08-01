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



if ! [ $(id -u) = 0 ]; then
   echo "This script must be run as root"
   exit 1
fi

WORKDIR="/etc/wireguard"
WGSUBNET="192.168.6.0/24"
WGSUBNET6="fd42:42:42:42::/112"

clear
PS3='Wireguard config, choose an option: '
opts=("Server" "Client" "Set pubkey" "Quit")
select fav in "${opts[@]}"; do
    case $fav in
        "Server")
	    echo "**to be run on SERVER**"
	    read -p "Enter server ip [1.2.3.4]: " serverip
	    serverip=${serverip:-1.2.3.4}
	    read -p "Enter server port [41194]: " IPORT
	    IPORT=${IPORT:-41194}
	    read -p "Enter server interface [eth0]: " IFACE
	    IFACE=${IFACE:-eth0}
	    read -p "Enter server private ip [192.168.6.1/24]: " srvprivip
	    srvprivip=${srvprivip:-192.168.6.1\/24}
	    SRVIPPORT="$serverip:$IPORT"
	    echo "Server: $SRVIPPORT, server interface: $IFACE, server priv. ip: $srvprivip"
	    read -p "Shall i run server config? [enter] to continue or CTRL+C to exit" cont
            echo "Running server configuration"
	    source server_configure.sh
            echo "Complete"
	    exit
            ;;
        "Client")
	    echo "**to be run on CLIENT, configure a peer **"
	    read -p "Enter server ip [1.2.3.4]: " serverip
	    serverip=${serverip:-1.2.3.4}
	    read -p "Enter server port [41194]: " IPORT
	    IPORT=${IPORT:-41194}
	    read -p "Enter server pub key: " SRVPUB
	    SRVIPPORT="$serverip:$IPORT"
	    read -p "Enter peer private ip [192.168.6.2/24]: " peerprivip
	    peerprivip=${peerprivip:-192.168.6.2\/24}
	    echo "Server: $SRVIPPORT, server pub key: $SRVPUB, peer priv ip: $peerprivip"
	    read -p "Shall i run client config? [enter] to continue or CTRL+C to exit" cont
            echo "Running client configuration"
	    source client_configure.sh
            echo "Complete"
	    exit
            ;;
        "Set pubkey")
	    echo "**to be run on SERVER, adds a peer to the server **"
	    read -p "Enter client's pubkey for the server: " clipubkey
	    echo "Client's pub key: $clipubkey"
	    read -p "Shall i set client's pub key? [enter] to continue or CTRL+C to exit" cont
	    ##sed -i "s#PEER1PUB#$clipubkey#g" $WORKDIR/wg0.conf
	    ##sed -i "s/#SaveConfig/SaveConfig=true/g" $WORKDIR/wg0.conf
	    echo "adding peer to server"
tee -a $WORKDIR/wg0.conf <<EOF
[Peer]
PublicKey = $clipubkey
AllowedIPs = 192.168.6.0/24,fd42:42:42:42::/112
EOF
	    echo "restarting service"
	    systemctl restart wg-quick@wg0.service
            echo "Complete"
            break
            ;;
        "Quit")
            echo "Quit script"
            exit
            ;;
        *) echo "invalid option $REPLY";;
    esac
done



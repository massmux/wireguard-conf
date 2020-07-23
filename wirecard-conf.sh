#!/bin/bash


#if ! [ $(id -u) = 0 ]; then
#   echo "This script must be run as root"
#   exit 1
#fi

WORKDIR="/tmp/wireguard"
SRVPUB="xxxx"

clear
PS3='Wireguard config, chose an option: '
opts=("Server" "Client" "Set pubkey" "Quit")
select fav in "${opts[@]}"; do
    case $fav in
        "Server")
	    read -p "Enter server ip [1.2.3.4]: " serverip
	    serverip=${serverip:-1.2.3.4}
	    read -p "Enter server port [41194]: " IPORT
	    IPORT=${IPORT:-41194}
	    read -p "Enter server interface [eth0]: " IFACE
	    IFACE=${IFACE:-eth0}
	    SRVIPPORT="$serverip:$IPORT"
	    echo "Server: $SRVIPPORT, server interface: $IFACE"
	    echo "Shall i run server config? [enter] to continue or CTRL+C to exit"
	    read
            echo "Running server configuration"
	    source server_configure.sh
            echo "Complete"
	    exit
            ;;
        "Client")
	    read -p "Enter server ip [1.2.3.4]: " serverip
	    serverip=${serverip:-1.2.3.4}
	    read -p "Enter server port [41194]: " IPORT
	    IPORT=${IPORT:-41194}
	    SRVIPPORT="$serverip:$IPORT"
	    echo "Server: $SRVIPPORT"
	    echo "Shall i run client config? [enter] to continue or CTRL+C to exit"
	    read
            echo "Running client configuration"
	    source client_configure.sh
            echo "Complete"
	    exit
            ;;
        "Set pubkey")
	    read -p "Enter client's pubkey for the server: " clipubkey
            break
            ;;
        "Quit")
            echo "User requested exit"
            exit
            ;;
        *) echo "invalid option $REPLY";;
    esac
done



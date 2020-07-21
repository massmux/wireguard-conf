#!/bin/bash


#if ! [ $(id -u) = 0 ]; then
#   echo "This script must be run as root"
#   exit 1
#fi

WORKDIR="/tmp/wireguard"
#WORKDIR="/etc/wireguard"
##SRVIPPORT="159.69.107.228:41194"
SRVPUB="xxxx"

##IFACE="eth0"
##IPORT="41194"


PS3='Choose your option (main menu): '
opts=("Server" "Client" "Set pubkey" "Quit")
select fav in "${opts[@]}"; do
    case $fav in
        "Server")
	    echo "please enter server ip, es: 1.2.3.4"
	    read serverip
	    echo "please enter server port, es: 41194"
	    read IPORT
	    echo "please enter server interface, es: eth0"
	    read IFACE
	    SRVIPPORT="$serverip:$IPORT"
	    echo "Server: $SRVIPPORT, server interface: $IFACE"
	    echo "Shall i run server config? [enter] to continue or CTRL+C to exit"
	    read
            echo "Running server configuration"
	    source server_configure.sh
            ;;
        "Client")
	    echo "please enter server ip, es: 1.2.3.4"
	    read serverip
	    echo "please enter server port, es: 41194"
	    read IPORT
	    SRVIPPORT="$serverip:$IPORT"
	    echo "Server: $SRVIPPORT"
	    echo "Shall i run client config? [enter] to continue or CTRL+C to exit"
	    read
            echo "Running client configuration"
	    source client_configure.sh
            ;;
        "Set pubkey")
	    echo "Set client's pubkey on server (server config must be already set)"
            break
            ;;
        "Quit")
            echo "User requested exit"
            exit
            ;;
        *) echo "invalid option $REPLY";;
    esac
done



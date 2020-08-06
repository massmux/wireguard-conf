# wireguard-conf

 this script can be run on the VPS server in order to create a running configuration of wireguard VPN and also on linux client in order to connect to the server.

 the script has been tested on Ubuntu 20.04 server and peer. The server tested is VMB1 server on https://www.tritema.ch hosting provider. Cheap and easy to use vps server. On peer side we were behind a router on a lan

 the configuration is with a VPS with static public ip as a central vpn server. The peers connect to the server and they are behind a router. After the vpn connection they would be routed to the server and get that IP as public shown ip. By default the private network used is 192.168.6.0/24

 what is needed:

 - a vps server with public ip and ubuntu 20.04
 - your linux computer running in your private lan (as an example)
 - this configuration script

 procedure is simple:

 - run the script on the server, choose option 1 (server configuration), it will ask you about local network details and then install all the software needed;
 - after the script completes, it will prompt you the server public key. This is needed for adding peers;
 - at this point go on the client and run the same script, choosing option 2 (peer configuration). With this option all the software needed is installed on the peeer and the virtual network card is also configured;
 - the script will ask the server public key, so you can paste the value you got previously on the server;
 - finally the peers's public key is also shown;
 - now go back on the server, run the script again, choose option 3 (add peers) and paste the peer's key you just gathered on the peer. this would enable the peer connection to the server;
 - now all is setup;
 - you can run again on each peer you want to add to the same server;

 each peer will navigate the web showing the public ip of the server.

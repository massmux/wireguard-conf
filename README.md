# wireguard-conf

 this script can be run on the VPS server in order to create a running configuration of wireguard VPN and also on linux client in order to connect to the server.

 the script has been tested on Ubuntu 20.04 server and peer. The server tested is VMB1 server on https://www.tritema.ch hosting provider. Cheap and easy to use vps server. On peer side we were behind a router on a lan

 procedure is simple:

 - run the script on the server, choose option 1 (server configuration), it will ask you about local network details and then install all the software needed.
 - after the script completes, it will prompt you the server public key. This is needed for adding peers.
 - at this point go on the client and run the same script, choosing option 2 (peer configuration)
 - the script will ask the server public key, so you can paste the value you got previously on the server
 - finally the peers's public key is also shown
 - now go back on the server, run the script again, choose option 3 (add peers) and paste the peer's key you just gathered on the peer
 - now all is setup
 - you can run again on each peer you want to add to the same server



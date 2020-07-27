# wireguard-conf

 this script can be run on the VPS server in order to create a running configuration of wireguard VPN and also on linux client in order to connect to the server.

 the script has been tested on Ubuntu 20.04 server and client. The server tested is VMB1 server on https://www.tritema.ch hosting provider. Cheap and easy to use vps server.

 procedure is simple:

 - run the script on the server, choose option 1 (server), it will ask you about local network details and then install all the software needed.
 - after the script completes, it will prompt you the server public key.
 - at this point go on the client and run the same script, choosing option 2 (client)
 - the script will ask the server pub key, so you can paste the value you got previously on the server
 - finally the client's pub key is also shown
 - now go back on the server, run the script again, choose option 3 (set pub key) and paste the peer key you just had on the client
 - now all is setup



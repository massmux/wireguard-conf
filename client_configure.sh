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

mkdir $WORKDIR
cd $WORKDIR

echo "generating private/public key pair for this peer"
umask 077
wg genkey | tee privatekey | wg pubkey > publickey

clipub=`cat publickey`
clipriv=`cat privatekey`


echo "writing wg0.conf file"
tee wg0.conf <<EOF
[Interface]
PrivateKey = $clipriv
Address = $peerprivip

[Peer]
PublicKey = $SRVPUB
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = $SRVIPPORT
PersistentKeepalive = 15

EOF

echo "enabling the system"
systemctl enable wg-quick@wg0.service

echo "==== Peer public key ===="
echo "Peer public key is: $clipub"
echo "Add this key to the server, by choosing opt. 3"
echo "and then restart the peer: systemctl restart wg-quick@wg0.service"


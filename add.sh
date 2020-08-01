#!/bin/bash

tee -a $WORKDIR/wg0.conf <<EOF
[Peer]
PublicKey = $clipubkey
AllowedIPs = $WGSUBNET,$WGSUBNET6
EOF



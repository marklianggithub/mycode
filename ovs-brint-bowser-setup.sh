#!/bin/bash

# create an OvS bridge called castle-koopa
sudo ovs-vsctl add-br castle-koopa

# create network namespace
sudo ip netns add bowser &> /dev/null

# create bridge internal interface
sudo ovs-vsctl add-port castle-koopa bowser -- set interface bowser type=internal

# plug the OvS bridge internals into the peach namespace
sudo ip link set bowser netns bowser

# bring interface UP in bowser and peach
sudo ip netns exec bowser ip link set dev bowser up
sudo ip netns exec bowser ip link set dev lo up

# add IP address to interface
sudo ip netns exec bowser ip addr add 10.64.2.3/24 dev bowser


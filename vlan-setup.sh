#!/bin/bash

# create OvS bridges called donut-plains and castle-koopa
sudo ovs-vsctl add-br donut-plains
sudo ovs-vsctl add-br castle-koopa

# create network namespaces
sudo ip netns add peach &> /dev/null
sudo ip netns add bowser &> /dev/null
sudo ip netns add mario &> /dev/null
sudo ip netns add yoshi &> /dev/null

# create bridge internal interface
sudo ovs-vsctl add-port donut-plains bowser -- set interface bowser type=internal
sudo ovs-vsctl add-port donut-plains mario -- set interface mario type=internal
sudo ovs-vsctl add-port castle-koopa yoshi -- set interface yoshi type=internal
sudo ovs-vsctl add-port castle-koopa peach -- set interface peach type=internal

# plug the OvS bridge internals into the namespaces
sudo ip link set peach netns peach
sudo ip link set bowser netns bowser
sudo ip link set mario netns mario
sudo ip link set yoshi netns yoshi

# bring interface UP in for peach, bowser, mario, and yoshi
sudo ip netns exec peach ip link set dev peach up
sudo ip netns exec peach ip link set dev lo up
sudo ip netns exec bowser ip link set dev bowser up
sudo ip netns exec bowser ip link set dev lo up
sudo ip netns exec mario ip link set dev mario up
sudo ip netns exec mario ip link set dev lo up
sudo ip netns exec yoshi ip link set dev yoshi up
sudo ip netns exec yoshi ip link set dev lo up

# add IP address to interface
sudo ip netns exec peach ip addr add 10.90.90.2/24 dev peach
sudo ip netns exec bowser ip addr add 10.90.90.3/24 dev bowser
sudo ip netns exec mario ip addr add 10.70.70.2/24 dev mario
sudo ip netns exec yoshi ip addr add 10.70.70.3/24 dev yoshi

# add VLANs
sudo ovs-vsctl set port peach tag=90
sudo ovs-vsctl set port bowser tag=90
sudo ovs-vsctl set port mario tag=70
sudo ovs-vsctl set port yoshi tag=70

# create a port on each bridge (toad and metalmario) to connect them via patch
sudo ovs-vsctl add-port donut-plains toad -- set interface toad type=patch options:peer=metalmario
sudo ovs-vsctl add-port castle-koopa metalmario -- set interface metalmario type=patch options:peer=toad


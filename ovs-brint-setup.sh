#!/bin/bash

# create an OvS bridge called donut-plains
sudo ovs-vsctl add-br donut-plains

# create network namespaces
sudo ip netns add peach &> /dev/null
sudo ip netns add bowser &> /dev/null

# create bridge internal interface
sudo ovs-vsctl add-port donut-plains peach -- set interface peach type=internal
sudo ovs-vsctl add-port donut-plains bowser -- set interface bowser type=internal

# plug the OvS bridge internals into the peach and bowser namespaces
sudo ip link set peach netns peach
sudo ip link set bowser netns bowser

# bring interface UP in bowser and peach
sudo ip netns exec peach ip link set dev peach up
sudo ip netns exec bowser ip link set dev bowser up
sudo ip netns exec peach ip link set dev lo up
sudo ip netns exec bowser ip link set dev lo up

# add IP address to interface
sudo ip netns exec peach ip addr add 10.64.2.2/24 dev peach
sudo ip netns exec bowser ip addr add 10.64.2.3/24 dev bowser


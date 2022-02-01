#!/bin/bash

# create an OvS bridge called donut-plains
sudo ovs-vsctl add-br donut-plains

# create network namespaces
sudo ip netns add peach &> /dev/null

# create bridge internal interface
sudo ovs-vsctl add-port donut-plains peach -- set interface peach type=internal

# plug the OvS bridge internals into the peach namespace
sudo ip link set peach netns peach

# bring interface UP in bowser and peach
sudo ip netns exec peach ip link set dev peach up
sudo ip netns exec peach ip link set dev lo up

# add IP address to interface
sudo ip netns exec peach ip addr add 10.64.2.2/24 dev peach


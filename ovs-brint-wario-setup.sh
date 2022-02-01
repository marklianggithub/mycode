#!/bin/bash

# create an OvS bridge called wario-land
sudo ovs-vsctl add-br wario-land

# create network namespaces
sudo ip netns add wario &> /dev/null

# create bridge internal interface
sudo ovs-vsctl add-port wario-land wario -- set interface wario type=internal

# plug the OvS bridge internals into the wario namespace
sudo ip link set wario netns wario

# bring interface UP in wario
sudo ip netns exec wario ip link set dev wario up

# add IP address to interface
sudo ip netns exec wario ip addr add 10.64.0.10/24 dev wario


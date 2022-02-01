#!/bin/bash

# create an OvS bridge called yoshi-island
sudo ovs-vsctl add-br yoshi-island

# create network namespace
sudo ip netns add yoshi &> /dev/null

# create VETH
sudo ip link add yoshi2net type veth peer name net2yoshi &> /dev/null

# plug in VETH to namespace
sudo ip link set yoshi2net netns yoshi &> /dev/null

# add IP address assignments
sudo ip netns exec yoshi ip a add 10.64.0.11/24 dev yoshi2net &> /dev/null

# make all connections UP
sudo ip netns exec yoshi ip link set dev yoshi2net up &> /dev/null
sudo ip netns exec yoshi ip link set dev lo up &> /dev/null


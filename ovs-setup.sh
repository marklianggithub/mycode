#!/bin/bash

# create network namespaces
sudo ip netns add peach &> /dev/null
sudo ip netns add bowser &> /dev/null

# create VETH
sudo ip link add peach2net type veth peer name net2peach &> /dev/null
sudo ip link add bowser2net type veth peer name net2bowser &> /dev/null

# plug in VETH to namespace
sudo ip link set peach2net netns peach &> /dev/null
sudo ip link set bowser2net netns bowser &> /dev/null

# add IP address assignments
sudo ip netns exec peach ip a add 10.64.2.2/24 dev peach2net &> /dev/null
sudo ip netns exec bowser ip a add 10.64.2.3/24 dev bowser2net &> /dev/null

# make all connections UP
sudo ip netns exec peach ip link set dev peach2net up &> /dev/null
sudo ip netns exec peach ip link set dev lo up &> /dev/null
sudo ip netns exec bowser ip link set dev bowser2net up &> /dev/null
sudo ip netns exec bowser ip link set dev lo up &> /dev/null


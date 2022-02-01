#!/bin/bash
# TEARDOWN

# remove bridge
sudo ip link del dev br0 &> /dev/null

# remove VETH
sudo ip netns exec peach ip link delete peach2net &> /dev/null
sudo ip netns exec bowser ip link delete bowser2net &> /dev/null
sudo ip netns exec bowser ip link delete bowser2peach &> /dev/null

# remove network namespaces
sudo ip netns del peach &> /dev/null
sudo ip netns del bowser &> /dev/null


#!/bin/bash
# TEARDOWN

# delete bridge
sudo ovs-vsctl del-br donut-plains &> /dev/null

# delete network namespaces
sudo ip netns del peach &> /dev/null
sudo ip netns del bowser &> /dev/null


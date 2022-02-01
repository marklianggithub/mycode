#!/bin/bash
# TEARDOWN

# delete bridges
sudo ovs-vsctl del-br wario-land &> /dev/null
sudo ovs-vsctl del-br yoshi-island &> /dev/null

# delete network namespaces
sudo ip netns del wario &> /dev/null
sudo ip netns del yoshi &> /dev/null


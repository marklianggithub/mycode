#!/bin/bash

# 1. Create 2 namespaces
ip netns add h1
ip netns add h2

# 2. Create openvswitch
ovs-vsctl add-br s1

# 3. Create vethernet links
ip link add h1-eth1 type veth peer name s1-eth1
ip link add h2-eth1 type veth peer name s1-eth2

# 4. Move host ports into namespaces
ip link set h1-eth1 netns h1
ip link set h2-eth1 netns h2

# 5. Connect switch ports to OVS
ovs-vsctl add-port s1 s1-eth1
ovs-vsctl add-port s1 s1-eth2

# 6. Connect controller to switch
ovs-vsctl set-controller s1 tcp:127.0.0.1

# 7. Setup ip
ip netns exec h1 ifconfig h1-eth1 10.1
ip netns exec h1 ifconfig lo up
ip netns exec h2 ifconfig h2-eth1 10.2
ip netns exec h2 ifconfig lo up
ifconfig s1-eth1 up
ifconfig s1-eth2 up

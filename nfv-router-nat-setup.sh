#!/bin/bash

# create an OvS bridge called donut-plains
sudo ovs-vsctl add-br donut-plains

# create network namespaces
sudo ip netns add peach &> /dev/null
sudo ip netns add bowser &> /dev/null
sudo ip netns add mario &> /dev/null
sudo ip netns add yoshi &> /dev/null

# create bridge internal interface
sudo ovs-vsctl add-port donut-plains peach -- set interface peach type=internal
sudo ovs-vsctl add-port donut-plains bowser -- set interface bowser type=internal
sudo ovs-vsctl add-port donut-plains mario -- set interface mario type=internal
sudo ovs-vsctl add-port donut-plains yoshi -- set interface yoshi type=internal

# plug the OvS bridge internals into the namespaces
sudo ip link set peach netns peach
sudo ip link set bowser netns bowser
sudo ip link set mario netns mario
sudo ip link set yoshi netns yoshi

# bring interface UP in bowser and peach
sudo ip netns exec peach ip link set dev peach up
sudo ip netns exec bowser ip link set dev bowser up
sudo ip netns exec mario ip link set dev mario up
sudo ip netns exec yoshi ip link set dev yoshi up
sudo ip netns exec peach ip link set dev lo up
sudo ip netns exec bowser ip link set dev lo up
sudo ip netns exec mario ip link set dev lo up
sudo ip netns exec yoshi ip link set dev lo up


# add IP address to interface
sudo ip netns exec peach ip addr add 10.64.2.2/24 dev peach
sudo ip netns exec bowser ip addr add 10.64.2.3/24 dev bowser
sudo ip netns exec mario ip addr add 10.64.1.2/24 dev mario
sudo ip netns exec yoshi ip addr add 10.64.1.3/24 dev yoshi

# add VLANs
sudo ovs-vsctl set port peach tag=90
sudo ovs-vsctl set port bowser tag=90
sudo ovs-vsctl set port mario tag=70
sudo ovs-vsctl set port yoshi tag=70

# Create the NFV Router
sudo ip netns add router
sudo ovs-vsctl add-port donut-plains router1 -- set interface router1 type=internal
sudo ovs-vsctl add-port donut-plains router2 -- set interface router2 type=internal
sudo ip link set router1 netns router
sudo ip link set router2 netns router
sudo ip netns exec router ip a
sudo ip netns exec router ip link set dev router1 up && sudo ip netns exec router ip link set dev router2 up
sudo ip netns exec router ip addr add 10.64.1.1/24 dev router1
sudo ip netns exec router ip addr add 10.64.2.1/24 dev router2
sudo ovs-vsctl set port router1 tag=70
sudo ovs-vsctl set port router2 tag=90

# Add Default Routes to the host
sudo ip netns exec mario ip route add default via 10.64.1.1
sudo ip netns exec yoshi ip route add default via 10.64.1.1
sudo ip netns exec bowser ip route add default via 10.64.2.1
sudo ip netns exec peach ip route add default via 10.64.2.1

# Allow IP Forwarding in the kernel
cat << EOF >  10-ip-forwarding.conf
net.ipv4.ip_forward = 1
net.ipv6.conf.default.forwarding = 1
net.ipv6.conf.all.forwarding = 1
EOF
sudo cp 10-ip-forwarding.conf /etc/sysctl.d/10-ip-forwarding.conf
rm 10-ip-forwarding.conf
sudo ip netns exec router sysctl -p /etc/sysctl.d/10-ip-forwarding.conf


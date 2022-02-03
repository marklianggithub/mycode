#!/bin/bash

# create an OvS bridge called donut-plains
ovs-vsctl add-br donut-plains

# create network namespaces
ip netns add peach &> /dev/null
ip netns add bowser &> /dev/null
ip netns add mario &> /dev/null
ip netns add yoshi &> /dev/null

# create bridge internal interface
ovs-vsctl add-port donut-plains peach -- set interface peach type=internal
ovs-vsctl add-port donut-plains bowser -- set interface bowser type=internal
ovs-vsctl add-port donut-plains mario -- set interface mario type=internal
ovs-vsctl add-port donut-plains yoshi -- set interface yoshi type=internal

# plug the OvS bridge internals into the namespaces
ip link set peach netns peach
ip link set bowser netns bowser
ip link set mario netns mario
ip link set yoshi netns yoshi

# bring interface UP in bowser and peach
ip netns exec peach ip link set dev peach up
ip netns exec peach ip link set dev lo up
ip netns exec bowser ip link set dev bowser up
ip netns exec bowser ip link set dev lo up
ip netns exec mario ip link set dev mario up
ip netns exec mario ip link set dev lo up
ip netns exec yoshi ip link set dev yoshi up
ip netns exec yoshi ip link set dev lo up

# add IP address to interface
ip netns exec peach ip addr add 10.64.2.2/24 dev peach
ip netns exec bowser ip addr add 10.64.2.3/24 dev bowser
ip netns exec mario ip addr add 10.64.1.2/24 dev mario
ip netns exec yoshi ip addr add 10.64.1.3/24 dev yoshi

# Remove nasty routes that get put in place when you add an IP address
ip netns exec peach ip route del 10.64.2.0/24
ip netns exec bowser ip route del 10.64.2.0/24
ip netns exec mario ip route del 10.64.1.0/24
ip netns exec yoshi ip route del 10.64.1.0/24

# add VLANs
ovs-vsctl set port peach tag=90
ovs-vsctl set port bowser tag=90
ovs-vsctl set port mario tag=70
ovs-vsctl set port yoshi tag=70

# Create the NFV Router
ip netns add router
ovs-vsctl add-port donut-plains router1 -- set interface router1 type=internal
ovs-vsctl add-port donut-plains router2 -- set interface router2 type=internal
ip link set router1 netns router
ip link set router2 netns router
ip netns exec router ip a
ip netns exec router ip link set dev router1 up && sudo ip netns exec router ip link set dev router2 up
ip netns exec router ip addr add 10.64.1.1/24 dev router1
ip netns exec router ip addr add 10.64.2.1/24 dev router2
ip netns exec router ip route del 10.64.2.0/24
ip netns exec router ip route del 10.64.1.0/24
ovs-vsctl set port router1 tag=70
ovs-vsctl set port router2 tag=90

ip netns exec mario ip route add default via 10.64.1.1 dev mario onlink
ip netns exec yoshi ip route add default via 10.64.1.1 dev yoshi onlink
ip netns exec bowser ip route add default via 10.64.2.1 dev bowser onlink
ip netns exec peach ip route add default via 10.64.2.1 dev peach onlink

cat << EOF >  10-ip-forwarding.conf
net.ipv4.ip_forward = 1
net.ipv6.conf.default.forwarding = 1
net.ipv6.conf.all.forwarding = 1
EOF
cp 10-ip-forwarding.conf /etc/sysctl.d/10-ip-forwarding.conf
rm 10-ip-forwarding.conf
ip netns exec router sysctl -p /etc/sysctl.d/10-ip-forwarding.conf

# Connect the router to the root namespace
ip link add host2router type veth peer name router2host
ip link set dev router2host netns router
ip netns exec router ip addr add 10.64.3.1/24 dev router2host
ip netns exec router ip link set dev router2host up
ip netns exec router ip route del 10.64.0.0/24
ip addr add 10.64.3.2/24 dev host2router
ip netns exec router ip route add default dev router2host via 10.64.3.2 onlink

# New Stuff
ip netns exec router ip route add 10.64.1.0/24 dev router1
ip netns exec router ip route add 10.64.2.0/24 dev router2
ip netns exec router iptables -t nat -A POSTROUTING -j MASQUERADE
ip route del 10.64.0.0/20
ip route add 10.64.0.0/20 via 10.64.3.1 dev host2router onlink


echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -P FORWARD DROP && iptables -F FORWARD
iptables -t nat -F
iptables -t nat -A POSTROUTING -s 10.64.0.0/20 -o ens3 -j MASQUERADE
iptables -A FORWARD -i ens3 -o host2router -j ACCEPT
iptables -A FORWARD -o ens3 -i host2router -j ACCEPT


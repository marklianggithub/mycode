#!/bin/bash

# create an OvS bridge called donut-plains
ovs-vsctl add-br donut-plains

# create network namespaces
ip netns add mar &> /dev/null
ip netns add car &> /dev/null
ip netns add tar &> /dev/null
ip netns add par &> /dev/null

# create bridge internal interface
ovs-vsctl add-port donut-plains mar -- set interface mar type=internal
ovs-vsctl add-port donut-plains car -- set interface car type=internal
ovs-vsctl add-port donut-plains tar -- set interface tar type=internal
ovs-vsctl add-port donut-plains par -- set interface par type=internal

# plug the OvS bridge internals into the namespaces
ip link set mar netns mar
ip link set car netns car
ip link set tar netns tar
ip link set par netns par

# bring interface UP in car and mar
ip netns exec mar ip link set dev mar up
ip netns exec mar ip link set dev lo up
ip netns exec car ip link set dev car up
ip netns exec car ip link set dev lo up
ip netns exec tar ip link set dev tar up
ip netns exec tar ip link set dev lo up
ip netns exec par ip link set dev par up
ip netns exec par ip link set dev lo up

# add IP address to interface
ip netns exec mar ip addr add 10.64.10.2/24 dev mar
ip netns exec car ip addr add 10.64.10.3/24 dev car
ip netns exec tar ip addr add 10.64.11.2/24 dev tar
ip netns exec par ip addr add 10.64.11.3/24 dev par

# Remove nasty routes that get put in place when you add an IP address
ip netns exec mar ip route del 10.64.10.0/24
ip netns exec car ip route del 10.64.10.0/24
ip netns exec tar ip route del 10.64.11.0/24
ip netns exec par ip route del 10.64.11.0/24

# add VLANs
ovs-vsctl set port mar tag=2
ovs-vsctl set port car tag=2
ovs-vsctl set port tar tag=90
ovs-vsctl set port par tag=90

# Create the NFV Router
ip netns add router
ovs-vsctl add-port donut-plains router1 -- set interface router1 type=internal
ovs-vsctl add-port donut-plains router2 -- set interface router2 type=internal
ip link set router1 netns router
ip link set router2 netns router
ip netns exec router ip a
ip netns exec router ip link set dev router1 up && sudo ip netns exec router ip link set dev router2 up
ip netns exec router ip addr add 10.64.11.1/24 dev router1
ip netns exec router ip addr add 10.64.10.1/24 dev router2
ip netns exec router ip route del 10.64.10.0/24
ip netns exec router ip route del 10.64.11.0/24
ovs-vsctl set port router1 tag=90
ovs-vsctl set port router2 tag=2

ip netns exec tar ip route add default via 10.64.11.1 dev tar onlink
ip netns exec par ip route add default via 10.64.11.1 dev par onlink
ip netns exec car ip route add default via 10.64.10.1 dev car onlink
ip netns exec mar ip route add default via 10.64.10.1 dev mar onlink

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
ip netns exec router ip addr add 10.64.4.1/24 dev router2host
ip netns exec router ip link set dev router2host up
ip netns exec router ip route del 10.64.0.0/24
ip addr add 10.64.4.2/24 dev host2router
ip netns exec router ip route add default dev router2host via 10.64.4.2 onlink

# New Stuff
ip netns exec router ip route add 10.64.11.0/24 dev router1
ip netns exec router ip route add 10.64.10.0/24 dev router2
ip netns exec router iptables -t nat -A POSTROUTING -j MASQUERADE
ip route del 10.64.0.0/20
ip route add 10.64.0.0/20 via 10.64.4.1 dev host2router onlink


echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -P FORWARD DROP && iptables -F FORWARD
iptables -t nat -F
iptables -t nat -A POSTROUTING -s 10.64.0.0/20 -o ens3 -j MASQUERADE
iptables -A FORWARD -i ens3 -o host2router -j ACCEPT
iptables -A FORWARD -o ens3 -i host2router -j ACCEPT
  

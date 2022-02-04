#!/bin/bash
set -euox pipefail

# Install
sudo apt install -y wireguard
python3 -m pip install --user j2cli

ssh-keyscan -t rsa alpha   >> ~/.ssh/known_hosts
ssh-keyscan -t rsa bravo   >> ~/.ssh/known_hosts
ssh-keyscan -t rsa charlie >> ~/.ssh/known_hosts
ssh-keygen -H
rm ~/.ssh/known_hosts.old

ssh alpha   sudo apt install -y wireguard 
ssh bravo   sudo apt install -y wireguard 
ssh charlie sudo apt install -y wireguard 

mkdir -p ~/wg
pushd ~/wg

### Key generation
mkdir -p keys
umask 077
wg genkey | tee   keys/alpha.key | wg pubkey >   keys/alpha.pub
wg genkey | tee   keys/bravo.key | wg pubkey >   keys/bravo.pub
wg genkey | tee keys/charlie.key | wg pubkey > keys/charlie.pub
wg genkey | tee    keys/bchd.key | wg pubkey >    keys/bchd.pub
umask 022

export WG_ALPHA_PUB=$(cat keys/alpha.pub)
export WG_ALPHA_KEY=$(cat keys/alpha.key)
export WG_ALPHA_IP=$(dig +short +search alpha)
export WG_BRAVO_PUB=$(cat keys/bravo.pub)
export WG_BRAVO_KEY=$(cat keys/bravo.key)
export WG_BRAVO_IP=$(dig +short +search bravo)
export WG_CHARLIE_PUB=$(cat keys/charlie.pub)
export WG_CHARLIE_KEY=$(cat keys/charlie.key)
export WG_CHARLIE_IP=$(dig +short +search charlie)
export WG_BCHD_PUB=$(cat keys/bchd.pub)
export WG_BCHD_KEY=$(cat keys/bchd.key)
export WG_BCHD_IP=$(dig +short +search bchd)

### Configuration Generation
mkdir -p j2
wget -q https://labs.alta3.com/courses/sd-wan/scripts/wg-netns/alpha.conf.j2 -O j2/alpha.conf.j2
wget -q https://labs.alta3.com/courses/sd-wan/scripts/wg-netns/bravo.conf.j2 -O j2/bravo.conf.j2
wget -q https://labs.alta3.com/courses/sd-wan/scripts/wg-netns/charlie.conf.j2 -O j2/charlie.conf.j2
wget -q https://labs.alta3.com/courses/sd-wan/scripts/wg-netns/bchd.conf.j2 -O j2/bchd.conf.j2

mkdir -p conf
j2 j2/alpha.conf.j2   > conf/alpha.conf
j2 j2/bravo.conf.j2   > conf/bravo.conf
j2 j2/charlie.conf.j2 > conf/charlie.conf
j2 j2/bchd.conf.j2    > conf/bchd.conf


cat conf/alpha.conf   | ssh alpha   sudo tee /etc/wireguard/wg0.conf
cat conf/bravo.conf   | ssh bravo   sudo tee /etc/wireguard/wg0.conf
cat conf/charlie.conf | ssh charlie sudo tee /etc/wireguard/wg0.conf
sudo cp conf/bchd.conf /etc/wireguard/wg0.conf
popd

### Startup

sudo ip netns add warp
ssh alpha   sudo ip netns add warp
ssh bravo   sudo ip netns add warp
ssh charlie sudo ip netns add warp

sudo ip link add wg0 type wireguard
ssh alpha   sudo ip link add dev wg0 type wireguard
ssh bravo   sudo ip link add dev wg0 type wireguard
ssh charlie sudo ip link add dev wg0 type wireguard

sudo ip link set wg0 netns warp
ssh alpha   sudo ip link set wg0 netns warp
ssh bravo   sudo ip link set wg0 netns warp
ssh charlie sudo ip link set wg0 netns warp

sudo ip netns exec warp wg setconf wg0 /etc/wireguard/wg0.conf
ssh alpha   sudo ip netns exec warp wg setconf wg0 /etc/wireguard/wg0.conf
ssh bravo   sudo ip netns exec warp wg setconf wg0 /etc/wireguard/wg0.conf
ssh charlie sudo ip netns exec warp wg setconf wg0 /etc/wireguard/wg0.conf

sudo ip -n warp -4 address add 10.67.0.1/32 dev wg0
ssh alpha   sudo ip -n warp -4 address add 10.64.0.1/32 dev wg0
ssh bravo   sudo ip -n warp -4 address add 10.65.0.1/32 dev wg0
ssh charlie sudo ip -n warp -4 address add 10.66.0.1/32 dev wg0

sudo ip -n warp link set mtu 1500 up dev wg0
ssh alpha   sudo ip -n warp link set mtu 1420 up dev wg0 
ssh bravo   sudo ip -n warp link set mtu 1420 up dev wg0 
ssh charlie sudo ip -n warp link set mtu 1420 up dev wg0 

sudo ip -n warp -4 route add 10.64.0.0/16 dev wg0
sudo ip -n warp -4 route add 10.65.0.0/16 dev wg0
sudo ip -n warp -4 route add 10.66.0.0/16 dev wg0
ssh alpha   sudo ip -n warp -4 route add 10.65.0.0/16 dev wg0
ssh alpha   sudo ip -n warp -4 route add 10.66.0.0/16 dev wg0
ssh alpha   sudo ip -n warp -4 route add 10.67.0.1/32 dev wg0
ssh bravo   sudo ip -n warp -4 route add 10.64.0.0/16 dev wg0
ssh bravo   sudo ip -n warp -4 route add 10.66.0.0/16 dev wg0
ssh bravo   sudo ip -n warp -4 route add 10.67.0.1/32 dev wg0
ssh charlie sudo ip -n warp -4 route add 10.64.0.0/16 dev wg0
ssh charlie sudo ip -n warp -4 route add 10.65.0.0/16 dev wg0
ssh charlie sudo ip -n warp -4 route add 10.67.0.1/32 dev wg0

sudo ip netns exec warp ping 10.64.0.1 -c 1 -W 1
sudo ip netns exec warp ping 10.65.0.1 -c 1 -W 1
sudo ip netns exec warp ping 10.66.0.1 -c 1 -W 1

ssh alpha   sudo ip netns exec warp ping 10.65.0.1 -c 1 -W 1
ssh alpha   sudo ip netns exec warp ping 10.66.0.1 -c 1 -W 1
ssh alpha   sudo ip netns exec warp ping 10.67.0.1 -c 1 -W 1

ssh bravo   sudo ip netns exec warp ping 10.64.0.1 -c 1 -W 1
ssh bravo   sudo ip netns exec warp ping 10.66.0.1 -c 1 -W 1
ssh bravo   sudo ip netns exec warp ping 10.67.0.1 -c 1 -W 1

ssh charlie sudo ip netns exec warp ping 10.64.0.1 -c 1 -W 1
ssh charlie sudo ip netns exec warp ping 10.65.0.1 -c 1 -W 1
ssh charlie sudo ip netns exec warp ping 10.67.0.1 -c 1 -W 1


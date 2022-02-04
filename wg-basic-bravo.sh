#!/bin/bash
set -euox pipefail

# Install
python3 -m pip install --user j2cli
ssh-keyscan -t rsa bravo   >> ~/.ssh/known_hosts
ssh-keygen -H
rm ~/.ssh/known_hosts.old

ssh bravo   sudo apt install -y wireguard 
mkdir -p ~/wg
pushd ~/wg

### Configuration Generation
export WG_ALPHA_PUB=$(cat keys/alpha.pub)
export WG_ALPHA_KEY=$(cat keys/alpha.key)
export WG_BRAVO_PUB=$(cat keys/bravo.pub)
export WG_BRAVO_KEY=$(cat keys/bravo.key)
export WG_CHARLIE_PUB=$(cat keys/charlie.pub)
export WG_CHARLIE_KEY=$(cat keys/charlie.key)
export WG_BCHD_PUB=$(cat keys/bchd.pub)
export WG_BCHD_KEY=$(cat keys/bchd.key)

mkdir -p j2
wget -q https://labs.alta3.com/courses/sd-wan/scripts/wg-basic/bravo.conf.j2 -O j2/bravo.conf.j2
mkdir -p conf
j2 j2/bravo.conf.j2   > conf/bravo.conf
cat conf/bravo.conf   | ssh bravo   sudo tee /etc/wireguard/wg0.conf
popd

### Starup
ssh bravo   sudo ip link add dev wg0 type wireguard
ssh bravo   sudo wg setconf wg0 /etc/wireguard/wg0.conf
ssh bravo   sudo ip -4 address add 10.65.0.1/32 dev wg0
ssh bravo   sudo ip link set mtu 1500 up dev wg0 
ssh bravo   sudo ip -4 route add 10.64.0.0/16 dev wg0
ssh bravo   sudo ip -4 route add 10.66.0.0/16 dev wg0
ssh bravo   sudo ip -4 route add 10.67.0.1/32 dev wg0

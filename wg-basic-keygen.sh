#!/bin/bash
set -euox pipefail

# Install
sudo apt install -y wireguard

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
popd

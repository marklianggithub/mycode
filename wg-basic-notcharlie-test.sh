#!/bin/bash
set -uox pipefail

ssh-keyscan -t rsa alpha   >> ~/.ssh/known_hosts
ssh-keyscan -t rsa bravo   >> ~/.ssh/known_hosts
ssh-keygen -H
rm ~/.ssh/known_hosts.old

ping 10.64.0.1 -c 1 -W 1
ping 10.65.0.1 -c 1 -W 1

ssh alpha   ping 10.65.0.1 -c 1 -W 1
ssh alpha   ping 10.67.0.1 -c 1 -W 1

ssh bravo   ping 10.64.0.1 -c 1 -W 1
ssh bravo   ping 10.67.0.1 -c 1 -W 1
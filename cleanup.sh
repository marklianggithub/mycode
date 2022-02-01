#!/bin/bash
sudo ip link del dev br0
sudo ip netns exec peach ip link delete peach2net
sudo ip netns exec bowser ip link delete bowser2net
sudo ip netns del peach
sudo ip netns del bowser


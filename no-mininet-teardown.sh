#!/bin/bash

# 1. Delete openvswitch
ovs-vsctl del-br s1


# 2. Delete the 2 namespaces
ip netns delete h1
ip netns delete h2


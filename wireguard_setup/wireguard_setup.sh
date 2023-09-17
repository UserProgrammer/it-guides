#!/bin/bash

# Install Wireguard
apt update && apt install -y wireguard

# Setup virtual network device
ip link add dev wg0 type wireguard
ip link set wg0 up

# Generate private and public keys
mkdir ~/wireguard
cd ~/wireguard
wg genkey | tee privatekey | wg pubkey > publickey

# Configure Wireguard
wg set wg0 listen-port 51820 private-key ~/wireguard/privatekey

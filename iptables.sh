#!/bin/bash

# vars
VPN_PROTOCOL="udp";
VPN_PORT=1194;

# Flush all existing settings
iptables -t nat -F;
iptables -t mangle -F;
iptables -F;
iptables -X;


# Block all
iptables -P OUTPUT DROP;
iptables -P INPUT DROP;
iptables -P FORWARD DROP;

# Allow `localhost` communication
iptables -A INPUT -i lo -j ACCEPT;
iptables -A OUTPUT -o lo -j ACCEPT;


# Allow communication with DHCP server
iptables -A OUTPUT -d 255.255.255.255 -j ACCEPT;
iptables -A INPUT -s 255.255.255.255 -j ACCEPT;


# Allow communication within your local network
iptables -A INPUT -s 192.168.200.0/24 -d 192.168.200.0/24 -j ACCEPT;
iptables -A OUTPUT -s 192.168.200.0/24 -d 192.168.200.0/24 -j ACCEPT;


# Allow established sessions to receive traffic
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT;


# Allow TUN
iptables -A INPUT -i tun+ -j ACCEPT;
iptables -A FORWARD -i tun+ -j ACCEPT;
iptables -A FORWARD -o tun+ -j ACCEPT;
iptables -t nat -A POSTROUTING -o tun+ -j MASQUERADE;
iptables -A OUTPUT -o tun+ -j ACCEPT;


# Allow VPN connection
iptables -I OUTPUT 1 -p $VPN_PROTOCOL --destination-port $VPN_PORT -m comment --comment "Allow VPN connection" -j ACCEPT;


# Block All
iptables -A OUTPUT -j DROP;
iptables -A INPUT -j DROP;
iptables -A FORWARD -j DROP;

# Save
echo "[+] Saving..";
iptables-save > /etc/iptables/rules.v4
echo "[+] Saved.";

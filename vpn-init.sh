#!/bin/sh -e
bash /etc/openvpn/iptables.sh &
sleep 15
sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
bash /etc/openvpn/connect.sh &

exit 0

#!/bin/bash
echo "net.ipv4.ip_forward = 1" > /etc/sysctl.conf
sysctl -p
while true
do
rm -rf ipvanish/*
rm -rf configs.zip*
wget https://configs.ipvanish.com/configs/configs.zip
unzip -d ipvanish/ configs.zip > /dev/null
rm -f /etc/openvpn/ca.ipvanish.com.crt
cp ipvanish/ca.ipvanish.com.crt /etc/openvpn/

#vpn_sum=$(ls ipvanish/ | wc -l)
vpn=$(ls -d /root/ipvanish/* | shuf -n 1)
echo "selected vpn - " $vpn
cat $vpn > /etc/openvpn/client.conf
sed -i '/auth-user-pass/d' /etc/openvpn/client.conf
echo "route 0.0.0.0 128.0.0.0 net_gateway" >> /etc/openvpn/client.conf
echo "route 128.0.0.0 128.0.0.0 net_gateway" >> /etc/openvpn/client.conf
echo "auth-user-pass pass.txt" >> /etc/openvpn/client.conf
systemctl restart openvpn@client.service
sleep 10s
echo "create routing"
ip rule del fwmark 1 table vpn
ip rule add fwmark 1 table vpn

ip route del default dev tun0 table vpn
ip route add default dev tun0 table vpn
systemctl restart shadowsocks-libev.service
sleep 24h
done

#!/bin/bash
while true
do
proxy_sum=$(cat proxy-list.sh | wc -l)
proxy_num=$(( $RANDOM % $proxy_sum + 1 ))
proxy=$(sed -n $proxy_num'p' proxy-list.sh)

proxy_ip=$(echo ${proxy//:/ } | awk '{print $1}')
proxy_port=$(echo ${proxy//:/ } | awk '{print $2}')
proxy_user=$(echo ${proxy//:/ } | awk '{print $3}')
proxy_password=$(echo ${proxy//:/ } | awk '{print $4}')

cat >/etc/redsocks.conf <<EOF
base {
        log_debug = off;
        log_info = on;
        log = "syslog:daemon";
        daemon = on;
        user = redsocks;
        group = redsocks;
        redirector = iptables;
}

redsocks {
        local_ip = 127.0.0.1;
        local_port = 1080;
        ip = $proxy_ip;
        port = $proxy_port;
        type = socks5;

        login = "$proxy_user";
        password = "$proxy_password";
}
EOF
iptables -t nat -F OUTPUT
iptables -t nat -I OUTPUT -p tcp -m owner --uid-owner root -j REDIRECT --to-port 1080
systemctl restart redsocks.service
echo $proxy_ip
sleep 30
done

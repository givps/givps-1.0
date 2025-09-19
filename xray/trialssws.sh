#!/bin/bash
# Quick Setup | Script Setup Manager
# Edition : Stable Edition 1.0
# Author  : givps
# License : MIT
# (C) Copyright 2023
# =========================================
# Warna
RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'; ORANGE='\033[0;33m'
BLUE='\033[0;34m'; PURPLE='\033[0;35m'; CYAN='\033[0;36m'; LIGHT='\033[0;37m'
# ==========================================

MYIP=$(wget -qO- ipv4.icanhazip.com)
domain=$(cat /etc/xray/domain)
tls=$(grep -w "Shadowsocks WS TLS" ~/log-install.txt | cut -d: -f2 | sed 's/ //g')
ntls=$(grep -w "Shadowsocks WS none TLS" ~/log-install.txt | cut -d: -f2 | sed 's/ //g')

# === Fungsi auto-cleaner expired ===
clean_expired() {
    today=$(date +"%Y-%m-%d")
    for file in /etc/shadowsocks/trial/*.conf; do
        [ -e "$file" ] || continue
        user=$(basename "$file" .conf)
        exp=$(cat "$file")
        if [[ "$today" > "$exp" ]]; then
            sed -i "/^### $user $exp/,/^},{/d" /etc/xray/config.json
            rm -f "$file"
            echo "Removed expired user: $user"
        fi
    done
    systemctl restart xray
}

# Bersihkan expired dulu
mkdir -p /etc/shadowsocks/trial
clean_expired

# === Generate trial baru ===
user=trial$(tr -dc 'A-Z0-9' </dev/urandom | head -c4)
cipher="aes-128-gcm"
uuid=$(cat /proc/sys/kernel/random/uuid)
masaaktif=1
exp=$(date -d "$masaaktif days" +"%Y-%m-%d")

# Tambah ke config Xray
sed -i '/#ssws$/a\### '"$user $exp"'\
},{"password": "'"$uuid"'","method": "'"$cipher"'","email": "'"$user"'"' /etc/xray/config.json
sed -i '/#ssgrpc$/a\### '"$user $exp"'\
},{"password": "'"$uuid"'","method": "'"$cipher"'","email": "'"$user"'"' /etc/xray/config.json

# Encode Shadowsocks
echo -n "$cipher:$uuid" | base64 > /tmp/ss-raw
ss_b64=$(cat /tmp/ss-raw)

# Links
ss_link_tls="ss://${ss_b64}@${domain}:$tls?path=/ss-ws&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
ss_link_ntls="ss://${ss_b64}@${domain}:$ntls?path=/ss-ws&security=none&host=${domain}&type=ws#${user}"
ss_link_grpc="ss://${ss_b64}@${domain}:$tls?mode=gun&security=tls&type=grpc&serviceName=ss-grpc&sni=${domain}#${user}"

# Restart service
systemctl restart xray > /dev/null 2>&1
service cron restart > /dev/null 2>&1

# Output
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\\E[0;41;36m        Shadowsocks Trial          \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Remarks        : ${user}"
echo -e "Domain         : ${domain}"
echo -e "Wildcard       : (bug.com).${domain}"
echo -e "Port TLS       : ${tls}"
echo -e "Port none TLS  : ${ntls}"
echo -e "Port gRPC      : ${tls}"
echo -e "Password       : ${uuid}"
echo -e "Ciphers        : ${cipher}"
echo -e "Network        : ws/grpc"
echo -e "Path           : /ss-ws"
echo -e "ServiceName    : ss-grpc"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link TLS       : ${ss_link_tls}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link none TLS  : ${ss_link_ntls}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link gRPC      : ${ss_link_grpc}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Expired On     : $exp"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# Log + Expired file
echo "Shadowsocks Trial: $user | Exp: $exp" >> /etc/log-create-user.log
echo "$exp" > /etc/shadowsocks/trial/${user}.conf

read -n 1 -s -r -p "Press any key to back on menu"
m-ssws

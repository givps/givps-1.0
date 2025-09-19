#!/bin/bash
# Quick Setup | Script Setup Manager
# Edition : Stable Edition 1.0
# Author  : givps
# The MIT License (MIT)
# (C) Copyright 2023
# =========================================

RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'; ORANGE='\033[0;33m'
BLUE='\033[0;34m'; PURPLE='\033[0;35m'; CYAN='\033[0;36m'; LIGHT='\033[0;37m'

MYIP=$(wget -qO- ipv4.icanhazip.com);
echo "Checking VPS"
clear

source /var/lib/ipvps.conf
if [[ "$IP" = "" ]]; then
  domain=$(cat /etc/xray/domain)
else
  domain=$IP
fi

tls="$(cat ~/log-install.txt | grep -w "Shadowsocks WS TLS" | cut -d: -f2|sed 's/ //g')"
ntls="$(cat ~/log-install.txt | grep -w "Shadowsocks WS none TLS" | cut -d: -f2|sed 's/ //g')"

# =========================================
# Input User
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\\E[0;41;36m      Add Shadowsocks Account    \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    read -rp "User: " -e user
    CLIENT_EXISTS=$(grep -w $user /etc/xray/config.json | wc -l)

    if [[ ${CLIENT_EXISTS} == '1' ]]; then
        clear
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo -e "\\E[0;41;36m      Add Shadowsocks Account      \E[0m"
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo ""
        echo "A client with the specified name was already created, please choose another name."
        echo ""
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        read -n 1 -s -r -p "Press any key to back on menu"
        m-ssws
    fi
done

cipher="aes-128-gcm"
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (days): " masaaktif
exp=$(date -d "$masaaktif days" +"%Y-%m-%d")

# Tambah user ke config
sed -i '/#ssws$/a\### '"$user $exp"'\
},{"password": "'""$uuid""'","method": "'""$cipher""'","email": "'""$user""'"' /etc/xray/config.json
sed -i '/#ssgrpc$/a\### '"$user $exp"'\
},{"password": "'""$uuid""'","method": "'""$cipher""'","email": "'""$user""'"' /etc/xray/config.json

# Simpan database user
echo "$user $exp" >> /etc/xray/ss-user

# =========================================
# Generate Link
echo $cipher:$uuid > /tmp/log
shadowsocks_base64=$(cat /tmp/log)
echo -n "${shadowsocks_base64}" | base64 > /tmp/log1
shadowsocks_base64e=$(cat /tmp/log1)
rm -f /tmp/log /tmp/log1

shadowsockslink="ss://${shadowsocks_base64e}@bug.com:$tls?path=ss-ws&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
shadowsockslink1="ss://${shadowsocks_base64e}@bug.com:$ntls?path=ss-ws&security=none&host=${domain}&type=ws#${user}"
shadowsockslink2="ss://${shadowsocks_base64e}@${domain}:$tls?mode=gun&security=tls&type=grpc&serviceName=ss-grpc&sni=bug.com#${user}"

systemctl restart xray

# =========================================
# Buat file config client
cat > /home/vps/public_html/ss-$user.txt <<-END
... (isi config JSON sama seperti sebelumnya) ...
END

systemctl restart xray > /dev/null 2>&1
service cron restart > /dev/null 2>&1

# =========================================
# Output Informasi Akun
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\\E[0;41;36m        Shadowsocks Account      \E[0m"
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
echo -e "Link TLS       : ${shadowsockslink}"
echo -e "Link none TLS  : ${shadowsockslink1}"
echo -e "Link gRPC      : ${shadowsockslink2}"
echo -e "Expired On     : $exp"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# =========================================
# Auto Expired Script Generator
cat > /usr/local/bin/xray-cleaner <<'EOF'
#!/bin/bash
today=$(date +%Y-%m-%d)
config="/etc/xray/config.json"
db="/etc/xray/ss-user"

[[ ! -f $db ]] && exit 0

while read -r user exp; do
  if [[ $(date -d "$exp" +%s) -lt $(date -d "$today" +%s) ]]; then
    echo "User $user expired on $exp, removing..."
    sed -i "/^### $user $exp/,/},/d" $config
    sed -i "/$user $exp/d" $db
  fi
done < $db

systemctl restart xray
EOF

chmod +x /usr/local/bin/xray-cleaner

# Buat cron job kalau belum ada
if [[ ! -f /etc/cron.d/xray-cleaner ]]; then
cat > /etc/cron.d/xray-cleaner <<EOF
0 0 * * * root /usr/local/bin/xray-cleaner >/dev/null 2>&1
EOF
fi

read -n 1 -s -r -p "Press any key to back on menu"
m-ssws

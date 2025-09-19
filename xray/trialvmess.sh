#!/bin/bash
# Quick Setup | Script Setup Manager
# Edition : Stable Edition 1.0
# Author  : givps
# The MIT License (MIT)
# (C) Copyright 2023
# =========================================
# pewarna hidup
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
# ==========================================

MYIP=$(wget -qO- ipv4.icanhazip.com)
echo "Checking VPS..."
clear

# domain & ports
domain=$(cat /etc/xray/domain)
tls=$(grep -w "Vmess WS TLS" ~/log-install.txt | cut -d: -f2 | sed 's/ //g')
none=$(grep -w "Vmess WS none TLS" ~/log-install.txt | cut -d: -f2 | sed 's/ //g')

# trial user
user="trial$(tr -dc 'A-Z0-9' </dev/urandom | head -c4)"
uuid=$(cat /proc/sys/kernel/random/uuid)
masaaktif=1
exp=$(date -d "$masaaktif days" +"%Y-%m-%d")

# insert user ke config.json
sed -i '/#vmess$/a\### '"${user} ${exp}"'\
},{"id": "'"${uuid}"'","alterId": 0,"email": "'"${user}"'"}' /etc/xray/config.json

sed -i '/#vmessgrpc$/a\### '"${user} ${exp}"'\
},{"id": "'"${uuid}"'","alterId": 0,"email": "'"${user}"'"}' /etc/xray/config.json

# restart service
systemctl restart xray >/dev/null 2>&1
service cron restart >/dev/null 2>&1

# buat link json
wstls=$(cat <<EOF
{
  "v": "2",
  "ps": "${user}",
  "add": "${domain}",
  "port": "${tls}",
  "id": "${uuid}",
  "aid": "0",
  "net": "ws",
  "path": "/vmess",
  "type": "none",
  "host": "",
  "tls": "tls"
}
EOF
)

wsnontls=$(cat <<EOF
{
  "v": "2",
  "ps": "${user}",
  "add": "${domain}",
  "port": "${none}",
  "id": "${uuid}",
  "aid": "0",
  "net": "ws",
  "path": "/vmess",
  "type": "none",
  "host": "",
  "tls": "none"
}
EOF
)

grpc=$(cat <<EOF
{
  "v": "2",
  "ps": "${user}",
  "add": "${domain}",
  "port": "${tls}",
  "id": "${uuid}",
  "aid": "0",
  "net": "grpc",
  "path": "vmess-grpc",
  "type": "none",
  "host": "",
  "tls": "tls"
}
EOF
)

# encode ke base64
vmesslink1="vmess://$(echo "$wstls" | base64 -w 0)"
vmesslink2="vmess://$(echo "$wsnontls" | base64 -w 0)"
vmesslink3="vmess://$(echo "$grpc" | base64 -w 0)"

# tampilkan hasil
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;41;36m          Trial Vmess          \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Remarks        : ${user}"
echo -e "Domain         : ${domain}"
echo -e "Wildcard       : (bug.com).${domain}"
echo -e "Port TLS       : ${tls}"
echo -e "Port none TLS  : ${none}"
echo -e "Port gRPC      : ${tls}"
echo -e "ID             : ${uuid}"
echo -e "alterId        : 0"
echo -e "Security       : auto"
echo -e "Network        : ws / grpc"
echo -e "Path WS        : /vmess"
echo -e "ServiceName    : vmess-grpc"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link TLS       : ${vmesslink1}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link none TLS  : ${vmesslink2}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link gRPC      : ${vmesslink3}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Expired On     : $exp"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""

# auto-cleaner setup
cat >/usr/local/bin/xray-cleaner <<'EOL'
#!/bin/bash
today=$(date +%s)
config="/etc/xray/config.json"
tmpfile=$(mktemp)

while read -r line; do
    if [[ $line == "### "* ]]; then
        user=$(echo $line | cut -d ' ' -f 2)
        exp=$(echo $line | cut -d ' ' -f 3)
        exp_ts=$(date -d "$exp" +%s)
        if [[ $exp_ts -le $today ]]; then
            # hapus user expired
            sed -i "/^### $user $exp/,/^},{/d" $config
            echo "User $user expired removed"
        fi
    fi
done < <(grep '^### ' $config)

systemctl restart xray >/dev/null 2>&1
EOL

chmod +x /usr/local/bin/xray-cleaner

# pasang cron job jika belum ada
if ! crontab -l | grep -q "xray-cleaner"; then
    echo "*/30 * * * * /usr/local/bin/xray-cleaner >/dev/null 2>&1" >> /etc/cron.d/xray-cleaner
fi

read -n 1 -s -r -p "Press any key to back on menu"
m-vmess

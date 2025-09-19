#!/bin/bash
# Quick Setup | Script Setup Manager
# Edition : Stable Edition 1.0
# Author  : givps
# The MIT License (MIT)
# (C) Copyright 2023
# =========================================

# Pewarna hidup
RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'
ORANGE='\033[0;33m'; BLUE='\033[0;34m'; PURPLE='\033[0;35m'
CYAN='\033[0;36m'; LIGHT='\033[0;37m'

# ==========================================
# Getting
MYIP=$(wget -qO- ipv4.icanhazip.com)
echo "Checking VPS"
clear

source /var/lib/ipvps.conf
if [[ "$IP" = "" ]]; then
  domain=$(cat /etc/xray/domain)
else
  domain=$IP
fi

tls=$(grep -w "Trojan WS TLS" ~/log-install.txt | cut -d: -f2 | sed 's/ //g')
ntls=$(grep -w "Trojan WS none TLS" ~/log-install.txt | cut -d: -f2 | sed 's/ //g')

# ==========================================
# Input user
user_EXISTS=1
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${user_EXISTS} == '0' ]]; do
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[0;41;36m           TROJAN ACCOUNT          \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    read -rp "User: " -e user
    user_EXISTS=$(grep -w "$user" /etc/xray/config.json | wc -l)

    if [[ ${user_EXISTS} == '1' ]]; then
        clear
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo -e "\E[0;41;36m           TROJAN ACCOUNT          \E[0m"
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo ""
        echo "A client with the specified name was already created, please choose another name."
        echo ""
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        read -n 1 -s -r -p "Press any key to back on menu"
        m-trojan
    fi
done

uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (days): " masaaktif
exp=$(date -d "$masaaktif days" +"%Y-%m-%d")

# Tambah user ke config.json
sed -i '/#trojanws$/a\### '"$user $exp"'\
},{"password": "'"$uuid"'","email": "'"$user"'"}' /etc/xray/config.json
sed -i '/#trojangrpc$/a\### '"$user $exp"'\
},{"password": "'"$uuid"'","email": "'"$user"'"}' /etc/xray/config.json

# Simpan database user
echo "$user $exp" >> /etc/xray/trojan-user

# Generate link
trojanlink="trojan://${uuid}@bug.com:${tls}?path=%2Ftrojan-ws&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
trojanlink2="trojan://${uuid}@bug.com:${ntls}?path=%2Ftrojan-ws&security=none&host=${domain}&type=ws#${user}"
trojanlink1="trojan://${uuid}@${domain}:${tls}?mode=gun&security=tls&type=grpc&serviceName=trojan-grpc&sni=bug.com#${user}"

systemctl restart xray

# Output info akun
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-trojan.log
echo -e "\E[0;41;36m           TROJAN ACCOUNT           \E[0m" | tee -a /etc/log-create-trojan.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-trojan.log
echo -e "Remarks        : ${user}" | tee -a /etc/log-create-trojan.log
echo -e "Host/IP        : ${domain}" | tee -a /etc/log-create-trojan.log
echo -e "Wildcard       : (bug.com).${domain}" | tee -a /etc/log-create-trojan.log
echo -e "Port TLS       : ${tls}" | tee -a /etc/log-create-trojan.log
echo -e "Port none TLS  : ${ntls}" | tee -a /etc/log-create-trojan.log
echo -e "Port gRPC      : ${tls}" | tee -a /etc/log-create-trojan.log
echo -e "Key            : ${uuid}" | tee -a /etc/log-create-trojan.log
echo -e "Path           : /trojan-ws" | tee -a /etc/log-create-trojan.log
echo -e "ServiceName    : trojan-grpc" | tee -a /etc/log-create-trojan.log
echo -e "Link TLS       : ${trojanlink}" | tee -a /etc/log-create-trojan.log
echo -e "Link none TLS  : ${trojanlink2}" | tee -a /etc/log-create-trojan.log
echo -e "Link gRPC      : ${trojanlink1}" | tee -a /etc/log-create-trojan.log
echo -e "Expired On     : $exp" | tee -a /etc/log-create-trojan.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-trojan.log
echo "" | tee -a /etc/log-create-trojan.log

# ==========================================
# Auto Expired Script
cat > /usr/local/bin/trojan-cleaner <<'EOF'
#!/bin/bash
today=$(date +%Y-%m-%d)
config="/etc/xray/config.json"
db="/etc/xray/trojan-user"

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

chmod +x /usr/local/bin/trojan-cleaner

# Buat cron job
if [[ ! -f /etc/cron.d/trojan-cleaner ]]; then
cat > /etc/cron.d/trojan-cleaner <<EOF
0 0 * * * root /usr/local/bin/trojan-cleaner >/dev/null 2>&1
EOF
fi

read -n 1 -s -r -p "Press any key to back on menu"
m-trojan

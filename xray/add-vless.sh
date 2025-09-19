#!/bin/bash
# Quick Setup | Script Setup Manager
# Edition : Stable Edition 1.0
# Author  : givps
# The MIT License (MIT)
# (C) Copyright 2023
# =========================================

# Warna
RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'
ORANGE='\033[0;33m'; BLUE='\033[0;34m'; PURPLE='\033[0;35m'
CYAN='\033[0;36m'; LIGHT='\033[0;37m'

# ==========================================
# Ambil domain & port
MYIP=$(wget -qO- ipv4.icanhazip.com)
echo "Checking VPS..."
clear

source /var/lib/ipvps.conf
if [[ "$IP" = "" ]]; then
  domain=$(cat /etc/xray/domain)
else
  domain=$IP
fi

tls=$(grep -w "Vless WS TLS" ~/log-install.txt | cut -d: -f2 | sed 's/ //g')
none=$(grep -w "Vless WS none TLS" ~/log-install.txt | cut -d: -f2 | sed 's/ //g')

# ==========================================
# Input user
CLIENT_EXISTS=1
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m        Add Vless Account          \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    read -rp "User: " -e user
    CLIENT_EXISTS=$(grep -w "$user" /etc/xray/config.json | wc -l)

    if [[ ${CLIENT_EXISTS} == '1' ]]; then
        clear
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo -e "\E[44;1;39m        Add Vless Account          \E[0m"
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo ""
        echo "A client with the specified name already exists, please choose another name."
        echo ""
        read -n 1 -s -r -p "Press any key to back on menu"
        m-vless
    fi
done

# ==========================================
# Generate UUID & Expired
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (days): " masaaktif
exp=$(date -d "$masaaktif days" +"%Y-%m-%d")

# Tambahkan user ke config.json
sed -i '/#vless$/a\### '"$user $exp"'\
},{"id": "'"$uuid"'","email": "'"$user"'"}' /etc/xray/config.json

sed -i '/#vlessgrpc$/a\### '"$user $exp"'\
},{"id": "'"$uuid"'","email": "'"$user"'"}' /etc/xray/config.json

# Simpan database user
echo "$user $exp" >> /etc/xray/vless-user

# ==========================================
# Generate Vless link
vlesslink1="vless://${uuid}@${domain}:${tls}?path=/vless&security=tls&encryption=none&type=ws&sni=${domain}#${user}"
vlesslink2="vless://${uuid}@${domain}:${none}?path=/vless&encryption=none&type=ws#${user}"
vlesslink3="vless://${uuid}@${domain}:${tls}?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=${domain}#${user}"

systemctl restart xray

# ==========================================
# Output Info
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-vless.log
echo -e "\E[44;1;39m          Vless Account            \E[0m" | tee -a /etc/log-create-vless.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-vless.log
echo -e "Remarks        : ${user}" | tee -a /etc/log-create-vless.log
echo -e "Domain         : ${domain}" | tee -a /etc/log-create-vless.log
echo -e "Wildcard       : (bug.com).${domain}" | tee -a /etc/log-create-vless.log
echo -e "Port TLS       : $tls" | tee -a /etc/log-create-vless.log
echo -e "Port none TLS  : $none" | tee -a /etc/log-create-vless.log
echo -e "id             : ${uuid}" | tee -a /etc/log-create-vless.log
echo -e "Encryption     : none" | tee -a /etc/log-create-vless.log
echo -e "Network        : ws / grpc" | tee -a /etc/log-create-vless.log
echo -e "Path (WS)      : /vless" | tee -a /etc/log-create-vless.log
echo -e "ServiceName    : vless-grpc" | tee -a /etc/log-create-vless.log
echo -e "Link TLS       : ${vlesslink1}" | tee -a /etc/log-create-vless.log
echo -e "Link none TLS  : ${vlesslink2}" | tee -a /etc/log-create-vless.log
echo -e "Link gRPC      : ${vlesslink3}" | tee -a /etc/log-create-vless.log
echo -e "Expired On     : $exp" | tee -a /etc/log-create-vless.log
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" | tee -a /etc/log-create-vless.log
echo "" | tee -a /etc/log-create-vless.log

# ==========================================
# Auto Expired Script
cat > /usr/local/bin/vless-cleaner <<'EOF'
#!/bin/bash
today=$(date +%Y-%m-%d)
config="/etc/xray/config.json"
db="/etc/xray/vless-user"

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

chmod +x /usr/local/bin/vless-cleaner

# Buat cron job kalau belum ada
if [[ ! -f /etc/cron.d/vless-cleaner ]]; then
cat > /etc/cron.d/vless-cleaner <<EOF
0 0 * * * root /usr/local/bin/vless-cleaner >/dev/null 2>&1
EOF
fi

read -n 1 -s -r -p "Press any key to back on menu"
m-vless

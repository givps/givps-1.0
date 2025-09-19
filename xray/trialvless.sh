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
# Getting
MYIP=$(wget -qO- ipv4.icanhazip.com)
echo "Checking VPS..."
clear

# domain + ports
domain=$(cat /etc/xray/domain)
tls=$(grep -w "Vless WS TLS" ~/log-install.txt | cut -d: -f2 | sed 's/ //g')
none=$(grep -w "Vless WS none TLS" ~/log-install.txt | cut -d: -f2 | sed 's/ //g')

# generate trial user
user="trial$(tr -dc 'A-Z0-9' </dev/urandom | head -c4)"
uuid=$(cat /proc/sys/kernel/random/uuid)
masaaktif=1
exp=$(date -d "$masaaktif days" +"%Y-%m-%d")

# add to xray config (marker #vless & #vlessgrpc harus ada di config.json)
sed -i '/#vless$/a\#! '"${user} ${exp}"'\
},{"id": "'"${uuid}"'","email": "'"${user}"'"}' /etc/xray/config.json

sed -i '/#vlessgrpc$/a\#! '"${user} ${exp}"'\
},{"id": "'"${uuid}"'","email": "'"${user}"'"}' /etc/xray/config.json

# restart service
systemctl restart xray >/dev/null 2>&1
service cron restart >/dev/null 2>&1

# buat link
vlesslink1="vless://${uuid}@${domain}:${tls}?path=/vless&security=tls&encryption=none&type=ws&sni=${domain}#${user}"
vlesslink2="vless://${uuid}@${domain}:${none}?path=/vless&encryption=none&type=ws#${user}"
vlesslink3="vless://${uuid}@${domain}:${tls}?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=${domain}#${user}"

# simpan info trial
mkdir -p /etc/vless/trial
echo "${exp}" > /etc/vless/trial/${user}.conf
echo "VLESS Trial: ${user} | Exp: ${exp}" >> /etc/log-create-user.log

# auto cleaner
cat > /usr/local/bin/vless-cleaner <<'EOF'
#!/bin/bash
today=$(date +%Y-%m-%d)
config="/etc/xray/config.json"

for file in /etc/vless/trial/*.conf; do
    [ -e "$file" ] || continue
    user=$(basename "$file" .conf)
    exp=$(cat "$file")
    if [[ $(date -d "$exp" +%s) -le $(date -d "$today" +%s) ]]; then
        sed -i "/#! $user $exp/,/},/d" "$config"
        rm -f "$file"
        echo "Expired VLESS user $user removed on $today" >> /var/log/vless-cleaner.log
    fi
done

systemctl restart xray >/dev/null 2>&1
EOF

chmod +x /usr/local/bin/vless-cleaner

# tambahkan ke cron jika belum ada
if ! crontab -l | grep -q "vless-cleaner"; then
    (crontab -l 2>/dev/null; echo "10 0 * * * /usr/local/bin/vless-cleaner") | crontab -
fi

# output info akun
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\\E[44;1;39m        TRIAL VLESS        \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Remarks        : ${user}"
echo -e "Domain         : ${domain}"
echo -e "Wildcard       : (bug.com).${domain}"
echo -e "Port TLS       : ${tls}"
echo -e "Port none TLS  : ${none}"
echo -e "Port gRPC      : ${tls}"
echo -e "ID             : ${uuid}"
echo -e "Encryption     : none"
echo -e "Network        : ws / grpc"
echo -e "Path WS        : /vless"
echo -e "ServiceName gRPC : vless-grpc"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link TLS       : ${vlesslink1}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link none TLS  : ${vlesslink2}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link gRPC      : ${vlesslink3}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Expired On     : ${exp}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
m-vless

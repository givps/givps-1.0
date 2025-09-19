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
tls=$(grep -w "Trojan WS TLS" ~/log-install.txt | cut -d: -f2 | sed 's/ //g')
ntls=$(grep -w "Trojan WS none TLS" ~/log-install.txt | cut -d: -f2 | sed 's/ //g')

# generate trial user
user="trial$(tr -dc 'A-Z0-9' </dev/urandom | head -c4)"
uuid=$(cat /proc/sys/kernel/random/uuid)
masaaktif=1
exp=$(date -d "${masaaktif} days" +"%Y-%m-%d")

# add to xray config (trojan ws & trojan grpc markers must exist in config)
sed -i '/#trojanws$/a\#! '"${user} ${exp}"'\
},{"password": "'"${uuid}"'","email": "'"${user}"'"}' /etc/xray/config.json

sed -i '/#trojangrpc$/a\#! '"${user} ${exp}"'\
},{"password": "'"${uuid}"'","email": "'"${user}"'"}' /etc/xray/config.json

# restart xray to apply
systemctl restart xray >/dev/null 2>&1 || true
service cron restart >/dev/null 2>&1 || true

# build trojan links
trojanlink="trojan://${uuid}@${domain}:${tls}?path=%2Ftrojan-ws&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
trojanlink2="trojan://${uuid}@${domain}:${ntls}?path=%2Ftrojan-ws&security=none&host=${domain}&type=ws#${user}"
trojanlink1="trojan://${uuid}@${domain}:${tls}?mode=gun&security=tls&type=grpc&serviceName=trojan-grpc&sni=${domain}#${user}"

# ensure log & trial folder
mkdir -p /etc/trojan/trial
echo "${exp}" > /etc/trojan/trial/${user}.conf
echo "Trojan Trial: ${user} | Exp: ${exp}" >> /etc/log-create-user.log

# setup cleaner script
cat > /usr/local/bin/trojan-cleaner <<'EOF'
#!/bin/bash
today=$(date +%Y-%m-%d)
config="/etc/xray/config.json"

for file in /etc/trojan/trial/*.conf; do
    [ -e "$file" ] || continue
    user=$(basename "$file" .conf)
    exp=$(cat "$file")
    if [[ $(date -d "$exp" +%s) -le $(date -d "$today" +%s) ]]; then
        # hapus user dari config
        sed -i "/#! $user $exp/,/},/d" "$config"
        rm -f "$file"
        echo "Expired Trojan user $user removed on $today" >> /var/log/trojan-cleaner.log
    fi
done

systemctl restart xray >/dev/null 2>&1
EOF

chmod +x /usr/local/bin/trojan-cleaner

# add cron job if not exists
if ! crontab -l | grep -q "trojan-cleaner"; then
    (crontab -l 2>/dev/null; echo "5 0 * * * /usr/local/bin/trojan-cleaner") | crontab -
fi

# output
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\\E[0;41;36m           TRIAL TROJAN           \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Remarks        : ${user}"
echo -e "Host/IP        : ${domain}"
echo -e "Wildcard       : (bug.com).${domain}"
echo -e "Port TLS       : ${tls}"
echo -e "Port none TLS  : ${ntls}"
echo -e "Port gRPC      : ${tls}"
echo -e "Key            : ${uuid}"
echo -e "Path           : /trojan-ws"
echo -e "ServiceName    : trojan-grpc"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link TLS       : ${trojanlink}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link none TLS  : ${trojanlink2}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link gRPC      : ${trojanlink1}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Expired On     : ${exp}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
sleep 1
m-trojan

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

MYIP=$(wget -qO- ipv4.icanhazip.com);
echo "Checking VPS"
clear
cekray=$(grep -ow "XRAY" /root/log-install.txt | sort | uniq)
if [ "$cekray" = "XRAY" ]; then
  domainlama=$(cat /etc/xray/domain)
else
  domainlama=$(cat /etc/v2ray/domain)
fi

clear
echo -e "[ ${GREEN}INFO${NC} ] Start "
sleep 0.5
systemctl stop nginx
domain=$(cat /var/lib/ipvps.conf | cut -d'=' -f2)

Cek=$(lsof -i:80 | awk 'NR==2 {print $1}')
if [[ ! -z "$Cek" ]]; then
  echo -e "[ ${RED}WARNING${NC} ] Detected port 80 used by $Cek "
  systemctl stop $Cek
  sleep 1
  echo -e "[ ${GREEN}INFO${NC} ] Processing to stop $Cek "
fi

echo -e "[ ${GREEN}INFO${NC} ] Starting renew cert... "
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
/root/.acme.sh/acme.sh --installcert -d $domain \
  --fullchainpath /etc/xray/xray.crt \
  --keypath /etc/xray/xray.key --ecc

if [[ $? -eq 0 ]]; then
  echo -e "[ ${GREEN}INFO${NC} ] Renew cert done... "
else
  echo -e "[ ${RED}ERROR${NC} ] Renew cert gagal!"
  exit 1
fi

# simpan domain
echo $domain > /etc/xray/domain
echo $domain > /etc/v2ray/domain

# restart service
systemctl restart $Cek 2>/dev/null
systemctl restart nginx
systemctl restart xray 2>/dev/null
systemctl restart v2ray 2>/dev/null

echo -e "[ ${GREEN}INFO${NC} ] All finished... "
sleep 0.5

# setup auto renew via cron
cat > /usr/local/bin/renew-cert.sh << 'EOF'
#!/bin/bash
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || cat /etc/v2ray/domain 2>/dev/null)
if [[ -z "$DOMAIN" ]]; then
  echo "Domain tidak ditemukan!"
  exit 1
fi

CERT_FILE="/etc/xray/xray.crt"
if [[ -f "$CERT_FILE" ]]; then
  end_date=$(openssl x509 -enddate -noout -in "$CERT_FILE" | cut -d= -f2)
  end_sec=$(date -d "$end_date" +%s)
  now_sec=$(date +%s)
  days_left=$(( (end_sec - now_sec) / 86400 ))
else
  days_left=0
fi

if [[ $days_left -le 5 ]]; then
  echo "$(date) - Sertifikat akan expired dalam $days_left hari. Renewing..." >> /var/log/renew-cert.log
  /root/.acme.sh/acme.sh --renew -d "$DOMAIN" --force --ecc \
    --fullchainpath /etc/xray/xray.crt \
    --keypath /etc/xray/xray.key
  if [[ $? -eq 0 ]]; then
    echo "$(date) - Renew cert berhasil untuk $DOMAIN" >> /var/log/renew-cert.log
    systemctl restart nginx
    systemctl restart xray 2>/dev/null
    systemctl restart v2ray 2>/dev/null
  else
    echo "$(date) - Renew cert gagal untuk $DOMAIN" >> /var/log/renew-cert.log
  fi
else
  echo "$(date) - Cert masih berlaku $days_left hari, tidak perlu renew" >> /var/log/renew-cert.log
fi
EOF

chmod +x /usr/local/bin/renew-cert.sh

# tambahkan cron job (cek dulu biar tidak dobel)
crontab -l 2>/dev/null | grep -v "renew-cert.sh" | crontab -
(crontab -l 2>/dev/null; echo "0 3 * * * /usr/local/bin/renew-cert.sh >/dev/null 2>&1") | crontab -

echo -e "[ ${GREEN}INFO${NC} ] Auto renew cron job berhasil dibuat (jadwal: tiap jam 3 pagi)"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
m-domain

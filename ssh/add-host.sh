#!/bin/bash
# Quick Setup | Script Setup Manager
# Edition : Stable Edition 1.2
# Author  : givps
# License : MIT
# =========================================

MYIP=$(wget -qO- ipv4.icanhazip.com)
echo "Checking VPS..."
clear

# Cek XRAY
if grep -qw "XRAY" /root/log-install.txt 2>/dev/null; then
    cekray="XRAY Installed"
else
    cekray="Not Installed"
fi

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "      Add / Change Domain + SSL     "
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e " Current IP : $MYIP"
echo -e " XRAY Status: $cekray"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""

read -rp "Input Domain (example: mydomain.com): " domain
echo ""

if [[ -z "$domain" ]]; then
    echo -e "\033[0;31m[Error]\033[0m Domain tidak boleh kosong!"
    read -n 1 -s -r -p "Press any key to return to menu..."
    m-domain
    exit 1
fi

# Simpan domain
echo "IP=$domain" > /var/lib/ipvps.conf
echo "$domain" | tee /root/domain /etc/xray/domain /etc/v2ray/domain \
    /root/scdomain /root/xray/scdomain >/dev/null
echo -e "\033[0;32m[OK]\033[0m Domain berhasil diset: $domain"

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e " Proses pembuatan / perpanjangan SSL Certificate..."
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# Install acme.sh kalau belum ada
if [[ ! -f ~/.acme.sh/acme.sh ]]; then
    curl https://get.acme.sh | sh
    source ~/.bashrc
fi

# Set CA ke Let's Encrypt
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
~/.acme.sh/acme.sh --register-account -m admin@$domain --force

# Ambil Cloudflare API Token dari file atau manual input
if [[ -f /root/cf_api_token ]]; then
    CF_API_TOKEN=$(cat /root/cf_api_token)
else
    read -rp "Input Cloudflare API Token: " CF_API_TOKEN
    echo "$CF_API_TOKEN" > /root/cf_api_token
fi
export CF_Token="$CF_API_TOKEN"
export CF_Account_ID="" # opsional kalau token berbasis account

# Issue SSL wildcard via DNS API
~/.acme.sh/acme.sh --issue --dns dns_cf -d "$domain" -d "*.$domain" --force

# Install cert ke folder xray
mkdir -p /etc/xray
~/.acme.sh/acme.sh --install-cert -d "$domain" \
    --key-file /etc/xray/xray.key \
    --fullchain-file /etc/xray/xray.crt \
    --reloadcmd "systemctl restart xray"

# Bersihkan cron lama (jika ada)
crontab -l 2>/dev/null | grep -v "acme.sh --cron" | crontab -

# Tambahkan cron job auto-renew (cek harian jam 3 pagi)
(crontab -l 2>/dev/null; echo "0 3 * * * ~/.acme.sh/acme.sh --cron --home ~/.acme.sh > /dev/null 2>&1") | crontab -

echo -e "\033[0;32m[OK]\033[0m Sertifikat SSL (wildcard) berhasil diperbarui."
echo -e "\033[0;32m[OK]\033[0m Cron auto-renew berhasil diset (jadwal: 03:00 setiap hari)."

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -n 1 -s -r -p "Press any key to return to menu..."
m-domain

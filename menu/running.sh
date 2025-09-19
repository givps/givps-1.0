#!/bin/bash
# Quick Setup | Script Setup Manager
# Edition : Stable Edition 1.0
# Author  : givps
# License : MIT
# =========================================

# ========== Colors ==========
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Shortcuts
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red()   { echo -e "\\033[31;1m${*}\\033[0m"; }

clear

# ========== OS INFO ==========
source /etc/os-release
OS_NAME=$NAME
OS_VERSION=$VERSION_ID

# ========== VPS INFO ==========
IPVPS=$(curl -s ipv4.icanhazip.com)
#LOC=$(curl -s https://ipapi.co/country_code 2>/dev/null)
#CITY=$(curl -s https://ipinfo.io/city 2>/dev/null)
#ISP=$(curl -s https://ipapi.co/org 2>/dev/null)

# ========== SYSTEMD SERVICE CHECKER ==========
check_service() {
  local svc="$1"
  if systemctl is-active --quiet "$svc"; then
    echo -e "${GREEN}Running${NC} (No Error)"
  else
    echo -e "${RED}Not Running${NC} (Error)"
  fi
}

# ========== SERVICE STATUS ==========
status_ssh=$(check_service ssh)
status_dropbear=$(check_service dropbear)
status_stunnel=$(check_service stunnel4)
status_fail2ban=$(check_service fail2ban)
status_cron=$(check_service cron)
status_vnstat=$(check_service vnstat)
status_tls_v2ray=$(check_service xray)
status_nontls_v2ray=$(check_service xray)
status_tls_vless=$(check_service xray)
status_nontls_vless=$(check_service xray)
status_virus_trojan=$(check_service xray)
status_shadowsocks=$(check_service xray)
swstls=$(check_service ws-stunnel.service)
swsdrop=$(check_service ws-dropbear.service)

# ========== SYSTEM INFO ==========
total_ram=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)
kernel_ver=$(uname -r)
domain="$(cat /etc/xray/domain 2>/dev/null || echo '-')"

Name="VIP-MEMBERS"
Exp="Lifetime"

# ========== OUTPUT ==========
clear
echo -e "${YELLOW}-------------------------------------------------${NC}"
echo -e "${BLUE}               SYSTEM INFORMATION               ${NC}"
echo -e "${YELLOW}-------------------------------------------------${NC}"
echo -e "${GREEN} Hostname     ${NC}: $HOSTNAME"
echo -e "${GREEN} OS Name      ${NC}: $OS_NAME $OS_VERSION"
echo -e "${GREEN} Kernel       ${NC}: $kernel_ver"
echo -e "${GREEN} Total RAM    ${NC}: ${total_ram} MB"
echo -e "${GREEN} Public IP    ${NC}: $IPVPS"
#echo -e "${GREEN} City         ${NC}: $CITY"
#echo -e "${GREEN} Country      ${NC}: $LOC"
#echo -e "${GREEN} ASN/ISP      ${NC}: $ISP"
echo -e "${GREEN} Domain       ${NC}: $domain"
echo -e "${YELLOW}-------------------------------------------------${NC}"
echo -e "${BLUE}           SUBSCRIPTION INFORMATION             ${NC}"
echo -e "${YELLOW}-------------------------------------------------${NC}"
echo -e "${GREEN} Client Name  ${NC}: $Name"
echo -e "${GREEN} Exp Script   ${NC}: $Exp"
echo -e "${GREEN} Version      ${NC}: 1.0"
echo -e "${YELLOW}-------------------------------------------------${NC}"
echo -e "${BLUE}              SERVICE INFORMATION               ${NC}"
echo -e "${YELLOW}-------------------------------------------------${NC}"
echo -e "${GREEN} SSH / TUN            ${NC}: $status_ssh"
echo -e "${GREEN} Dropbear             ${NC}: $status_dropbear"
echo -e "${GREEN} Stunnel4             ${NC}: $status_stunnel"
echo -e "${GREEN} Fail2Ban             ${NC}: $status_fail2ban"
echo -e "${GREEN} Crons                ${NC}: $status_cron"
echo -e "${GREEN} Vnstat               ${NC}: $status_vnstat"
echo -e "${GREEN} XRAYS Vmess TLS      ${NC}: $status_tls_v2ray"
echo -e "${GREEN} XRAYS Vmess None TLS ${NC}: $status_nontls_v2ray"
echo -e "${GREEN} XRAYS Vless TLS      ${NC}: $status_tls_vless"
echo -e "${GREEN} XRAYS Vless None TLS ${NC}: $status_nontls_vless"
echo -e "${GREEN} XRAYS Trojan         ${NC}: $status_virus_trojan"
echo -e "${GREEN} Shadowsocks          ${NC}: $status_shadowsocks"
echo -e "${GREEN} Websocket TLS        ${NC}: $swstls"
echo -e "${GREEN} Websocket Dropbear   ${NC}: $swsdrop"
echo -e "${YELLOW}-------------------------------------------------${NC}"
echo -e "${BLUE}              t.me/givpn_grup                   ${NC}"
echo -e "${YELLOW}-------------------------------------------------${NC}"
echo ""

read -n 1 -s -r -p "Press any key to go back to menu..."
menu

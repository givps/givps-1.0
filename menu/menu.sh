#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition 1.0
# Author  : givps
# The MIT License (MIT)
# (C) Copyright 2023
# =========================================

MYIP=$(curl -sS ipv4.icanhazip.com)
clear

# Colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
PURPLE='\e[35m'
CYAN='\e[36m'
NC='\e[0m' # No Color
BOLD='\e[1m'

# VPS Information
domain=$(cat /etc/xray/domain 2>/dev/null)

# Certificate Status (days remaining)
cert_file="$HOME/.acme.sh/${domain}_ecc/${domain}.key"
if [[ -f "$cert_file" ]]; then
    modifyTime=$(stat -c %Y "$cert_file")
    currentTime=$(date +%s)
    stampDiff=$(( currentTime - modifyTime ))
    days=$(( stampDiff / 86400 ))
    remainingDays=$(( 90 - days ))
    [[ $remainingDays -le 0 ]] && tlsStatus="expired" || tlsStatus="$remainingDays days"
else
    tlsStatus="No certificate found"
fi

# OS Uptime
uptime="$(uptime -p | cut -d " " -f 2-10)"

# Network Statistics
dtoday="$(vnstat -i eth0 | awk '/today/ {print $2,$3}')"
utoday="$(vnstat -i eth0 | awk '/today/ {print $5,$6}')"
ttoday="$(vnstat -i eth0 | awk '/today/ {print $8,$9}')"

# Yesterday
dyest="$(vnstat -i eth0 | awk '/yesterday/ {print $2,$3}')"
uyest="$(vnstat -i eth0 | awk '/yesterday/ {print $5,$6}')"
tyest="$(vnstat -i eth0 | awk '/yesterday/ {print $8,$9}')"

# Current Month
dmon="$(vnstat -i eth0 -m | grep "$(date +"%b '%y")" | awk '{print $3,$4}')"
umon="$(vnstat -i eth0 -m | grep "$(date +"%b '%y")" | awk '{print $6,$7}')"
tmon="$(vnstat -i eth0 -m | grep "$(date +"%b '%y")" | awk '{print $9,$10}')"

# User Info
Exp2="Lifetime"
Name="VIP-MEMBERS"

# CPU Information
cpu_usage1=$(ps aux | awk '{sum+=$3} END {print sum}')
cores=$(grep -c "^processor" /proc/cpuinfo)
cpu_usage=$(awk -v c="$cores" -v u="$cpu_usage1" 'BEGIN {printf "%.2f%%", (u/c)}')

#CITY=$(curl -s https://ipinfo.io/city)
#LOC=$(curl -s https://ipapi.co/country_code)
#ISP=$(curl -s https://ipapi.co/org)
DAY=$(date +%A)
DATE=$(date +%m/%d/%Y)
DATE2=$(date -R | cut -d " " -f -5)
IPVPS=$(curl -s ipv4.icanhazip.com)

cname=$(awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo)
freq=$(awk -F: '/cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo)
tram=$(free -m | awk 'NR==2 {print $2}')
uram=$(free -m | awk 'NR==2 {print $3}')
fram=$(free -m | awk 'NR==2 {print $4}')

clear
echo -e "${YELLOW} -------------------------------------------------${NC}"
echo -e "${BLUE}                  VPS INFORMATION                 ${NC}"
echo -e "${YELLOW} -------------------------------------------------${NC}"
echo -e "${GREEN} OS            ${NC}: $(hostnamectl | grep 'Operating System' | cut -d ' ' -f5-)"
echo -e "${GREEN} Uptime        ${NC}: $uptime"
echo -e "${GREEN} Public IP     ${NC}: $IPVPS"
#echo -e "${GREEN} City          ${NC}: $CITY"
#echo -e "${GREEN} Country       ${NC}: $LOC"
#echo -e "${GREEN} ASN           ${NC}: $ISP"
echo -e "${GREEN} Domain        ${NC}: $domain"
echo -e "${GREEN} TLS Cert      ${NC}: $tlsStatus"
echo -e "${GREEN} Date & Time   ${NC}: $DATE2"
echo -e "${YELLOW} -------------------------------------------------${NC}"
echo -e "${BLUE}                    RAM INFO                      ${NC}"
echo -e "${YELLOW} -------------------------------------------------${NC}"
echo -e "${GREEN} RAM Used      ${NC}: $uram MB"
echo -e "${GREEN} RAM Total     ${NC}: $tram MB"
echo -e "${YELLOW} -------------------------------------------------${NC}"
echo -e "${BLUE}                     MENU                         ${NC}"
echo -e "${YELLOW} -------------------------------------------------${NC}"
echo -e "${CYAN} 1${NC} : Menu SSH"
echo -e "${CYAN} 2${NC} : Menu Vmess"
echo -e "${CYAN} 3${NC} : Menu Vless"
echo -e "${CYAN} 4${NC} : Menu Trojan"
echo -e "${CYAN} 5${NC} : Menu Shadowsocks"
echo -e "${CYAN} 6${NC} : Menu Setting"
echo -e "${CYAN} 7${NC} : Status Service"
echo -e "${CYAN} 8${NC} : Clear RAM Cache"
echo -e "${CYAN} 9${NC} : Reboot VPS"
echo -e "${CYAN} x${NC} : Exit Script (run again with: menu)"
echo -e "${YELLOW} -------------------------------------------------${NC}"
echo -e "${GREEN} Client Name   ${NC}: $Name"
echo -e "${GREEN} Expired       ${NC}: $Exp2"
echo -e "${YELLOW} -------------------------------------------------${NC}"
echo -e "${CYAN} ----------------- t.me/givpn_grup -----------------${NC}"
echo ""
read -p " Select menu : " opt
echo ""

case $opt in
  1) clear ; m-sshovpn ;;
  2) clear ; m-vmess ;;
  3) clear ; m-vless ;;
  4) clear ; m-trojan ;;
  5) clear ; m-ssws ;;
  6) clear ; m-system ;;
  7) clear ; running ;;
  8) clear ; clearcache ;;
  9) clear ; reboot ;;
  x) exit ;;
  *) echo "Invalid selection." ; sleep 1 ; menu ;;
esac

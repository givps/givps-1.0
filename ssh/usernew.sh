#!/bin/bash
# Quick Setup | Script Setup Manager
# Edition : Stable Edition 1.3
# Author  : givps
# The MIT License (MIT)
# (C) Copyright 2023
# =========================================

# Colors
red='\e[1;31m'
green='\e[1;32m'
blue='\e[1;34m'
NC='\e[0m'

# Get IP & Domain
MYIP=$(wget -qO- ipv4.icanhazip.com)
logfile="/root/log-install.txt"

echo "Checking VPS..."
sleep 1
clear

if grep -qw "XRAY" $logfile; then
    domain=$(cat /etc/xray/domain)
else
    domain=$(cat /etc/v2ray/domain)
fi

# Get ports from log
portsshws=$(grep -w "SSH Websocket" $logfile | cut -d: -f2 | awk '{print $1}')
wsssl=$(grep -w "SSH SSL Websocket" $logfile | cut -d: -f2 | awk '{print $1}')
openssh=$(grep -w "OpenSSH" $logfile | cut -d: -f2 | awk '{print $1}')
ssl=$(grep -w "Stunnel4" $logfile | cut -d: -f2)

# User input
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;41;36m            SSH ACCOUNT            \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -p "Username (Enter = random): " Login
read -p "Password (Enter = random): " Pass
read -p "Active Days (Enter = 30): " expdays

# Defaults if empty
if [[ -z "$Login" ]]; then
    Login="user$(shuf -i 1000-9999 -n 1)"
    echo -e "Auto-generated Username: ${green}$Login${NC}"
fi

if [[ -z "$Pass" ]]; then
    Pass=$(</dev/urandom tr -dc A-Za-z0-9 | head -c8)
    echo -e "Auto-generated Password: ${green}$Pass${NC}"
fi

if [[ -z "$expdays" ]]; then
    expdays=30
    echo -e "Default Expiration: ${green}$expdays days${NC}"
fi

# Check if user already exists
if id "$Login" &>/dev/null; then
    echo -e "${red}Error:${NC} User $Login already exists!"
    exit 1
fi

# Create user
useradd -e $(date -d "$expdays days" +"%Y-%m-%d") -s /bin/false -M $Login
echo -e "$Pass\n$Pass\n" | passwd $Login &>/dev/null
expdate=$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')
IP=$(curl -sS ifconfig.me)

# Save to log file
{
    echo -e "\n================ SSH ACCOUNT ================\n"
    {
        echo "Username      : $Login"
        echo "Password      : $Pass"
        echo "Expired On    : $expdate"
        echo "IP Address    : $IP"
        echo "Host/Domain   : $domain"
        echo "OpenSSH       : $openssh"
        echo "SSH WS        : $portsshws"
        echo "SSH SSL WS    : $wsssl"
        echo "SSL/TLS       : $ssl"
        echo "UDPGW Ports   : 7100-7900"
    } | column -t -s ":"
    
    echo -e "\n================ PAYLOADS ==================\n"
    echo "WebSocket Payload (WSS)"
    echo "GET wss://bug.com HTTP/1.1[crlf]Host: ${domain}[crlf]Upgrade: websocket[crlf][crlf]"
    echo
    echo "WebSocket Payload (WS)"
    echo "GET / HTTP/1.1[crlf]Host: $domain[crlf]Upgrade: websocket[crlf][crlf]"
    echo -e "\n============================================\n"
} | tee -a /etc/log-create-ssh.log

echo "" | tee -a /etc/log-create-ssh.log
read -n 1 -s -r -p "Press any key to return to menu..."
m-sshovpn

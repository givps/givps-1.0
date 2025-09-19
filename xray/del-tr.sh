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
MYIP=$(wget -qO- ipv4.icanhazip.com);
echo "Checking VPS"
clear

config="/etc/xray/config.json"

NUMBER_OF_CLIENTS=$(grep -c -E "^#! " "$config")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m     ⇱ Delete Trojan Account ⇲     \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "  • You have no existing clients!"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    read -n 1 -s -r -p "   Press any key to back on menu"
    m-trojan
    exit 0
fi

clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m     ⇱ Delete Trojan Account ⇲     \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "  User        Expired"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
grep -E "^#! " "$config" | cut -d ' ' -f 2-3 | column -t | sort | uniq | nl
echo -e ""
echo -e "  • [NOTE] Press ENTER to go back to menu"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

read -rp "   Input Username : " user
if [[ -z "$user" ]]; then
    m-trojan
else
    exp=$(grep -wE "^#! $user" "$config" | cut -d ' ' -f 3 | sort | uniq)
    if [[ -z "$exp" ]]; then
        echo -e "\n${RED}User not found!${NC}"
        sleep 2
        m-trojan
    fi
    sed -i "/^#! $user $exp/,/^},{/d" "$config"
    systemctl restart xray > /dev/null 2>&1
    clear
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m     ⇱ Delete Trojan Account ⇲     \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "   • Account Deleted Successfully"
    echo -e ""
    echo -e "   • Client Name : $user"
    echo -e "   • Expired On  : $exp"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    read -n 1 -s -r -p "   Press any key to back on menu"
    m-trojan
fi

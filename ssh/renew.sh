#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition 1.0
# Author  : givps
# License : MIT
# (C) Copyright 2023
# =========================================

MYIP=$(wget -qO- ipv4.icanhazip.com)

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;41;36m               RENEW  USER                \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo

read -p "Username : " User
if id "$User" &>/dev/null; then
    read -p "Extend (days): " Days

    if [[ -z "$Days" || ! "$Days" =~ ^[0-9]+$ ]]; then
        echo "❌ Invalid number of days!"
        exit 1
    fi

    Today=$(date +%s)
    Extend=$(( Days * 86400 ))
    Expire_On=$(( Today + Extend ))

    Expiration=$(date -d @"$Expire_On" +%Y-%m-%d)
    Expiration_Display=$(date -d @"$Expire_On" '+%d %b %Y')

    # Renew user
    passwd -u "$User" >/dev/null 2>&1
    usermod -e "$Expiration" "$User"

    clear
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[0;41;36m               RENEW  USER                \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e ""
    echo -e " Username   : $User"
    echo -e " Days Added : $Days Day(s)"
    echo -e " Expires On : $Expiration_Display"
    echo -e ""
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
else
    clear
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[0;41;36m               RENEW  USER                \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e ""
    echo -e "   ❌ Username [$User] does not exist"
    echo -e ""
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
fi

read -n 1 -s -r -p "Press any key to return to menu..."
m-sshovpn

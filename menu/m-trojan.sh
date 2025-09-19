#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition 1.0
# Author  : givps
# License : MIT
# (C) Copyright 2023
# =========================================

MYIP=$(wget -qO- ipv4.icanhazip.com)
echo "Checking VPS..."
sleep 1
clear

# Warna
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
Blue="\033[36m"
Reset="\033[0m"

# ===== MENU TROJAN =====
echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"
echo -e "\E[0;100;33m           • TROJAN MENU •          \E[0m"
echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"
echo ""
echo -e " [${Blue}1${Reset}] Create Trojan Account"
echo -e " [${Blue}2${Reset}] Trial Trojan Account"
echo -e " [${Blue}3${Reset}] Extend Trojan Account"
echo -e " [${Blue}4${Reset}] Delete Trojan Account"
echo -e " [${Blue}5${Reset}] Check Trojan Logins"
echo -e " [${Blue}6${Reset}] List Created Accounts"
echo ""
echo -e " [${Red}0${Reset}] Back to Main Menu"
echo -e " [x] Exit"
echo ""
echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"
echo ""

read -rp " Select menu : " opt
echo ""

case $opt in
    1) clear ; add-tr ;;                       # Create Trojan Account
    2) clear ; trialtrojan ;;                  # Trial Trojan Account
    3) clear ; renew-tr ;;                     # Extend Trojan Account
    4) clear ; del-tr ;;                       # Delete Trojan Account
    5) clear ; cek-tr ;;                       # Check User Logins
    6) clear ; cat /etc/log-create-trojan.log ;;  # Show Created Accounts
    0) clear ; menu ;;                         # Back to Main Menu
    x|X) exit 0 ;;                             # Exit
    *) 
        echo -e "${Red}[Error]${Reset} Invalid option!"
        sleep 1
        m-trojan
        ;;
esac

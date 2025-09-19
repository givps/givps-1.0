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

# ===== SHADOWSOCKS MENU =====
echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"
echo -e "\E[0;100;33m       • SHADOWSOCKS MENU •        \E[0m"
echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"
echo ""
echo -e " [${Blue}1${Reset}] Create Shadowsocks Account"
echo -e " [${Blue}2${Reset}] Create Trial Shadowsocks"
echo -e " [${Blue}3${Reset}] Extend Shadowsocks Account"
echo -e " [${Blue}4${Reset}] Delete Shadowsocks Account"
echo -e " [${Blue}5${Reset}] List Created Accounts"
echo ""
echo -e " [${Red}0${Reset}] Back to Main Menu"
echo -e " [x] Exit"
echo ""
echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"
echo ""

read -rp " Select menu : " opt
echo ""

case $opt in
    1) clear ; add-ssws ;;                       # Create Account
    2) clear ; trialssws ;;                      # Trial Account
    3) clear ; renew-ssws ;;                     # Extend Account
    4) clear ; del-ssws ;;                       # Delete Account
    5) clear ; cat /etc/log-create-shadowsocks.log ;;  # Show User List
    0) clear ; menu ;;                           # Back to Menu
    x|X) exit 0 ;;                               # Exit
    *) 
        echo -e "${Red}[Error]${Reset} Invalid option!"
        sleep 1
        m-ssws
        ;;
esac

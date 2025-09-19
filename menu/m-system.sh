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

# ===== SYSTEM MENU =====
echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"
echo -e "\E[0;100;33m           • SYSTEM MENU •          \E[0m"
echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"
echo ""
echo -e " [${Blue}1${Reset}] Panel Domain"
echo -e " [${Blue}2${Reset}] VPS Speedtest"
echo -e " [${Blue}3${Reset}] Set Auto Reboot"
echo -e " [${Blue}4${Reset}] Restart All Services"
echo -e " [${Blue}5${Reset}] Check Bandwidth Usage"
echo -e " [${Blue}6${Reset}] Install TCP BBR"
echo -e " [${Blue}7${Reset}] DNS Changer"
echo ""
echo -e " [${Red}0${Reset}] Back to Main Menu"
echo -e " [x] Exit"
echo ""
echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"
echo ""

read -rp " Select menu : " opt
echo ""

case $opt in
    1) clear ; m-domain ;;       # Panel Domain
    2) clear ; speedtest ;;      # Speedtest VPS
    3) clear ; auto-reboot ;;    # Auto Reboot
    4) clear ; restart ;;        # Restart Services
    5) clear ; bw ;;             # Bandwidth Check
    6) clear ; m-tcp ;;          # TCP BBR Install
    7) clear ; m-dns ;;          # DNS Changer
    0) clear ; menu ;;           # Back to Menu
    x|X) exit 0 ;;               # Exit
    *) 
        echo -e "${Red}[Error]${Reset} Invalid option!"
        sleep 1
        m-system
        ;;
esac

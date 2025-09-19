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

# ===== DOMAIN MENU =====
echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"
echo -e "\E[0;100;33m           • DOMAIN MENU •          \E[0m"
echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"
echo -e "\E[0;100;33m  • Don't Forget to RENEW CERTIFICATE •  \E[0m"
echo -e "\E[0;100;33m        • After Changing Domain •        \E[0m"
echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"
echo ""
echo -e " [${Blue}1${Reset}] Change VPS Domain"
echo -e " [${Blue}2${Reset}] Renew Domain Certificate"
echo ""
echo -e " [${Red}0${Reset}] Back to System Menu"
echo -e " [x] Exit"
echo ""
echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"
echo ""

read -rp " Select menu : " opt
echo ""

case $opt in
    1) clear ; add-host ;;
    2) clear ; certv2ray ;;
    0) clear ; m-system ;;
    x|X) exit 0 ;;
    *) 
       echo -e "${Red}[Error]${Reset} Invalid option!"
       sleep 1
       m-domain
       ;;
esac

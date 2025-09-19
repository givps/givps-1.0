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

# ===== SSH MENU =====
echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"
echo -e "\E[0;100;33m            • SSH MENU •            \E[0m"
echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"
echo ""
echo -e " [${Blue} 1${Reset}] Create SSH & WS Account"
echo -e " [${Blue} 2${Reset}] Create Trial SSH & WS Account"
echo -e " [${Blue} 3${Reset}] Renew SSH & WS Account"
echo -e " [${Blue} 4${Reset}] Delete SSH & WS Account"
echo -e " [${Blue} 5${Reset}] Check User Login SSH & WS"
echo -e " [${Blue} 6${Reset}] List Members SSH & WS"
echo -e " [${Blue} 7${Reset}] Delete Expired SSH & WS Users"
echo -e " [${Blue} 8${Reset}] Set Autokill SSH"
echo -e " [${Blue} 9${Reset}] Check Multi-Login Users"
echo -e " [${Blue}10${Reset}] Show Created SSH Accounts"
echo -e " [${Blue}11${Reset}] Change SSH Banner"
echo -e " [${Blue}12${Reset}] Lock/Unlock SSH User"
echo ""
echo -e " [${Red} 0${Reset}] Back to Main Menu"
echo -e " [x] Exit"
echo ""
echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"
echo ""

read -rp " Select menu : " opt
echo ""

case $opt in
    1) clear ; usernew ;;
    2) clear ; trial ;;
    3) clear ; renew ;;
    4) clear ; hapus ;;
    5) clear ; cek ;;
    6) clear ; member ;;
    7) clear ; delete ;;
    8) clear ; autokill ;;
    9) clear ; ceklim ;;
   10) clear ; cat /etc/log-create-ssh.log ;;
   11) clear ; nano /etc/issue.net ;;
   12) clear ; user-lockunlock ;;
    0) clear ; menu ;;
    x|X) exit 0 ;;
    *) 
       echo -e "${Red}[Error]${Reset} Invalid option!"
       sleep 1
       m-sshovpn
       ;;
esac

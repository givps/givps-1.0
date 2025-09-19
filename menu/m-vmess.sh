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

# ===== MENU =====
echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"
echo -e "\E[0;100;33m           • VMESS MENU •          \E[0m"
echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"
echo -e ""
echo -e " [${Blue}1${Reset}] Create Account Vmess"
echo -e " [${Blue}2${Reset}] Trial Account Vmess"
echo -e " [${Blue}3${Reset}] Extend Account Vmess"
echo -e " [${Blue}4${Reset}] Delete Account Vmess"
echo -e " [${Blue}5${Reset}] Check User Login Vmess"
echo -e " [${Blue}6${Reset}] List Created Accounts"
echo -e ""
echo -e " [${Red}0${Reset}] Back to Menu"
echo -e " [x] Exit"
echo -e ""
echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"
echo -ne " Select menu : "

read opt
echo ""

case $opt in
    1) clear ; add-ws ;;                  # Create VMess Account
    2) clear ; trialvmess ;;              # Trial VMess
    3) clear ; renew-ws ;;                # Extend VMess
    4) clear ; del-ws ;;                  # Delete VMess
    5) clear ; cek-ws ;;                  # Check VMess Logins
    6) clear ; cat /etc/log-create-vmess.log ;;  # Show Created Accounts
    0) clear ; menu ;;                    # Back to Main Menu
    x|X) exit 0 ;;                        # Exit
    *) 
        echo -e "${Red}[Error]${Reset} Invalid option!"
        sleep 1
        m-vmess
        ;;
esac

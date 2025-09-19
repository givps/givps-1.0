#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition 1.0
# Author  : givps
# License : MIT
# (C) Copyright 2023
# =========================================

# Colors
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
Blue="\033[36m"
Reset="\033[0m"
Info="${Green}[Installed]${Reset}"
Error="${Red}[Not Installed]${Reset}"

# Check if Webmin is running
cek=$(netstat -ntlp 2>/dev/null | grep ":10000" | awk '{print $7}' | cut -d'/' -f2)

# ===== Functions =====
install_webmin() {
    IP=$(wget -qO- ipv4.icanhazip.com)
    clear
    echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"
    echo -e "\E[0;100;33m        • INSTALL WEBMIN •         \E[0m"
    echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}\n"
    
    echo -e "${Green}[Info]${Reset} Adding Webmin Repository"
    echo "deb http://download.webmin.com/download/repository sarge contrib" \
        > /etc/apt/sources.list.d/webmin.list

    apt install -y gnupg gnupg1 gnupg2 > /dev/null 2>&1
    wget -q http://www.webmin.com/jcameron-key.asc
    apt-key add jcameron-key.asc > /dev/null 2>&1
    rm -f jcameron-key.asc

    echo -e "${Green}[Info]${Reset} Installing Webmin..."
    apt update > /dev/null 2>&1
    apt install -y webmin > /dev/null 2>&1

    # Disable SSL (optional)
    sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf

    echo -e "${Green}[Info]${Reset} Restarting Webmin..."
    systemctl restart webmin

    echo -e "\n${Green}[Info]${Reset} Webmin installed successfully!"
    echo "Access Webmin at: http://$IP:10000"
    
    read -n 1 -s -r -p "Press any key to return to menu..."
    m-webmin
}

restart_webmin() {
    clear
    echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"
    echo -e "\E[0;100;33m        • RESTART WEBMIN •         \E[0m"
    echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}\n"

    echo "Restarting Webmin..."
    systemctl restart webmin > /dev/null 2>&1

    echo -e "\n${Green}[Info]${Reset} Webmin restarted successfully!"
    read -n 1 -s -r -p "Press any key to return to menu..."
    m-webmin
}

uninstall_webmin() {
    clear
    echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"
    echo -e "\E[0;100;33m       • UNINSTALL WEBMIN •        \E[0m"
    echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}\n"

    echo -e "${Green}[Info]${Reset} Removing Webmin repository..."
    rm -f /etc/apt/sources.list.d/webmin.list
    apt update > /dev/null 2>&1

    echo -e "${Green}[Info]${Reset} Uninstalling Webmin..."
    apt autoremove --purge -y webmin > /dev/null 2>&1

    echo -e "\n${Green}[Info]${Reset} Webmin uninstalled successfully!"
    read -n 1 -s -r -p "Press any key to return to menu..."
    m-webmin
}

# ===== Main Menu =====
if [[ "$cek" == "perl" ]]; then
    sts="$Info"
else
    sts="$Error"
fi

clear
echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"
echo -e "\E[0;100;33m          • WEBMIN MENU •          \E[0m"
echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}\n"

echo -e " Status : $sts"
echo -e " [${Blue}1${Reset}] Install Webmin"
echo -e " [${Blue}2${Reset}] Restart Webmin"
echo -e " [${Blue}3${Reset}] Uninstall Webmin"
echo -e ""
echo -e " [${Red}0${Reset}] Back to Menu"
echo -e " [x] Exit"
echo -e "\n${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"

read -rp " Select an option [0-3 or x]: " num
case $num in
    1) install_webmin ;;
    2) restart_webmin ;;
    3) uninstall_webmin ;;
    0) menu ;;
    x) exit 0 ;;
    *) echo -e "\n${Red}[Error] Invalid option!${Reset}" ; sleep 2 ; m-webmin ;;
esac

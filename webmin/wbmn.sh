#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition 1.0
# Author  : givps
# The MIT License (MIT)
# (C) Copyright 2023
# =========================================

clear
# Warna
Green_font_prefix="\033[32m" 
Red_font_prefix="\033[31m" 
Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[Installed]${Font_color_suffix}"
Error="${Red_font_prefix}[Not Installed]${Font_color_suffix}"

# Cek status Webmin
cek=$(netstat -ntlp 2>/dev/null | grep 10000 | awk '{print $7}' | cut -d'/' -f2)
if [[ "$cek" = "perl" ]]; then
    sts="${Info}"
else
    sts="${Error}"
fi

# Fungsi Install Webmin
install() {
    IP=$(wget -qO- ipv4.icanhazip.com)
    echo "Adding Webmin Repository..."
    echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list
    
    apt install gnupg gnupg1 gnupg2 -y
    wget -q http://www.webmin.com/jcameron-key.asc
    apt-key add jcameron-key.asc >/dev/null 2>&1
    rm -f jcameron-key.asc

    echo "Updating repository and installing Webmin..."
    apt update -y >/dev/null 2>&1
    apt install webmin -y

    # Nonaktifkan SSL agar bisa akses langsung via HTTP
    sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
    /etc/init.d/webmin restart

    clear
    echo -e "\n${Green_font_prefix}Webmin Installed Successfully!${Font_color_suffix}"
    echo "URL      : http://$IP:10000"
    echo "Username : root"
    echo "Password : (gunakan password VPS)"
}

# Fungsi Restart Webmin
restart() {
    echo "Restarting Webmin..."
    service webmin restart >/dev/null 2>&1
    sleep 1
    echo -e "${Green_font_prefix}Webmin Restarted Successfully!${Font_color_suffix}"
}

# Fungsi Uninstall Webmin
uninstall() {
    echo "Removing Webmin repository..."
    rm -f /etc/apt/sources.list.d/webmin.list
    apt update -y >/dev/null 2>&1
    
    echo "Uninstalling Webmin..."
    apt autoremove --purge webmin -y >/dev/null 2>&1
    
    clear
    echo -e "${Red_font_prefix}Webmin Uninstalled Successfully!${Font_color_suffix}"
}

# Menu
while true; do
    clear
    echo -e " =============================="
    echo -e "           Webmin Menu         "
    echo -e "        Default Port: 10000    "
    echo -e " =============================="
    echo -e " Status : $sts"
    echo -e "  1. Install Webmin"
    echo -e "  2. Restart Webmin"
    echo -e "  3. Uninstall Webmin"
    echo -e " "
    echo -e "  0. Back to Menu"
    echo -e " =============================="
    read -rp " Please Enter Number [0-3] : " num
    
    case $num in
        1) install ;;
        2) restart ;;
        3) uninstall ;;
        0) m-system ; break ;;
        *) echo "Invalid input!"; sleep 2 ;;
    esac
done

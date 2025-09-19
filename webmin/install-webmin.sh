#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition 1.0
# Author  : givps
# The MIT License (MIT)
# (C) Copyright 2023
# =========================================

BGreen='\e[1;32m'
NC='\e[0m'

clear
cd

# Update menu system
echo -e "${BGreen}Updating System Menu...${NC}"
rm -f /usr/bin/m-system
wget -q -O /usr/bin/m-system https://raw.githubusercontent.com/givps/AutoScriptXray/master/webmin/menu/m-system.sh
chmod +x /usr/bin/m-system

# Update Webmin panel
echo -e "${BGreen}Downloading Webmin Panel...${NC}"
rm -f /usr/bin/wbmn
wget -q -O /usr/bin/wbmn https://raw.githubusercontent.com/givps/AutoScriptXray/master/webmin/wbmn.sh
chmod +x /usr/bin/wbmn

# Optional: ADS Block Panel (disabled)
# echo -e "${BGreen}Downloading ADS Block Panel...${NC}"
# rm -f /usr/bin/helium
# wget -q -O /usr/bin/helium https://raw.githubusercontent.com/givps/AutoScriptXray/master/helium/helium.sh
# chmod +x /usr/bin/helium

# Bersihkan installer lama
rm -f /usr/bin/install-webmin

# Notifikasi reboot
echo -e "${BGreen}Setup selesai! Server akan reboot dalam 5 detik...${NC}"
sleep 5
reboot

#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition 1.0
# Author  : givps
# The MIT License (MIT)
# (C) Copyright 2023
# =========================================

# Warna
GREEN='\e[1;32m'
NC='\e[0m'

clear
cd

# Bersihkan file lama
rm -f debian.sh
rm -f /usr/bin/clearcache
rm -f /usr/bin/menu

# Info update
echo -e "${GREEN}Updating menu...${NC}"
sleep 1

# Download file terbaru
wget -q -O /usr/bin/clearcache "https://raw.githubusercontent.com/givps/givps-1.0/master/menu/clearcache.sh"
wget -q -O /usr/bin/menu "https://raw.githubusercontent.com/givps/givps-1.0/master/menu/menu.sh"

# Beri izin eksekusi
chmod +x /usr/bin/clearcache
chmod +x /usr/bin/menu

# Hapus sisa file
rm -f debian.sh

# Info reboot
echo -e "${GREEN}Auto rebooting in 5 seconds...${NC}"
sleep 5
reboot

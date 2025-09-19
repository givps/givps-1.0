#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition 1.0
# Author  : givps
# The MIT License (MIT)
# (C) Copyright 2023
# =========================================

# Ambil IP VPS
MYIP=$(wget -qO- ipv4.icanhazip.com)

clear
echo -e "[ \033[32mINFO\033[0m ] VPS Detected: $MYIP"
echo -e "[ \033[32mINFO\033[0m ] Clearing RAM Cache..."

# Jalankan perintah clear cache (butuh root)
sync
echo 3 > /proc/sys/vm/drop_caches

sleep 1
echo -e "[ \033[32mOK\033[0m ] RAM Cache cleared successfully"
echo ""
echo -e "[ \033[32mINFO\033[0m ] Returning to menu in 2 seconds..."
sleep 2

# Panggil menu utama
menu

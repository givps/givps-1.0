#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition 1.0
# Author  : givps
# License : MIT
# (C) Copyright 2023
# =========================================

# Warna
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
WHITE='\033[1;37m'

# Ambil IP VPS
MYIP=$(wget -qO- ipv4.icanhazip.com)
echo "Checking VPS..."
sleep 1
clear

dnsfile="/root/dns"

# Header
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}              DNS CHANGER${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Cek DNS aktif
if [[ -f "$dnsfile" ]]; then
    udns=$(cat "$dnsfile")
    echo -e "\n Active DNS : ${CYAN}$udns${NC}"
fi

echo -e ""
echo -e " [${CYAN}1${NC}] Change DNS (example: 1.1.1.1)"
echo -e " [${CYAN}2${NC}] Reset DNS to Google (8.8.8.8)"
echo -e " [${CYAN}3${NC}] Reboot after update DNS"
echo -e ""
echo -e " [${RED}0${NC}] Back To System Menu"
echo -e " [x] Exit"
echo -e ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""

read -rp " Select option [0-3]: " dns
echo ""

case $dns in
1)
    clear
    read -rp " Please insert DNS (IP only): " dns1
    if [[ -z "$dns1" ]]; then
        echo -e "${RED}Error:${NC} DNS cannot be empty!"
        sleep 2
        exec "$0"
    fi

    rm -f /etc/resolv.conf /etc/resolvconf/resolv.conf.d/head
    echo "$dns1" > "$dnsfile"

    echo "nameserver $dns1" > /etc/resolv.conf
    echo "nameserver $dns1" > /etc/resolvconf/resolv.conf.d/head

    systemctl restart resolvconf.service 2>/dev/null

    echo -e "\n${GREEN}Success:${NC} DNS $dns1 applied to VPS"
    cat /etc/resolvconf/resolv.conf.d/head
    sleep 2
    exec "$0"
    ;;
2)
    clear
    read -rp " Reset to Google DNS (8.8.8.8)? [y/N]: " answer
    case "$answer" in
        y|Y)
            rm -f "$dnsfile"
            echo "nameserver 8.8.8.8" > /etc/resolv.conf
            echo "nameserver 8.8.8.8" > /etc/resolvconf/resolv.conf.d/head
            echo -e "\n${GREEN}INFO:${NC} DNS reset to Google (8.8.8.8)"
            sleep 2
            ;;
        n|N|*)
            echo -e "\n${YELLOW}INFO:${NC} Operation cancelled by user."
            sleep 2
            ;;
    esac
    exec "$0"
    ;;
3)
    clear
    echo -e "${GREEN}INFO:${NC} Rebooting system..."
    sleep 2
    reboot
    ;;
0)
    clear
    m-system
    ;;
x|X)
    exit 0
    ;;
*)
    echo -e "${RED}Error:${NC} Invalid option!"
    sleep 2
    exec "$0"
    ;;
esac

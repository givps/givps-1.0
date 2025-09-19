#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition 1.1
# Author  : givps
# The MIT License (MIT)
# (C) Copyright 2023
# =========================================

# Warna
red='\e[1;31m'
green='\e[1;32m'
blue='\e[1;34m'
yellow='\e[1;33m'
NC='\e[0m' # No Color

# Fungsi Lock User
lock_user() {
    read -p "Input username to LOCK: " username
    if id "$username" &>/dev/null; then
        passwd -l "$username" &>/dev/null
        clear
        echo -e " "
        echo -e "==============================================="
        echo -e " Username : ${blue}$username${NC}"
        echo -e " Status   : ${red}LOCKED${NC}"
        echo -e "-----------------------------------------------"
        echo -e " Login access for user ${blue}$username${NC} has been disabled."
        echo -e "==============================================="
    else
        echo -e " "
        echo -e "${red}Error:${NC} Username '${yellow}$username${NC}' not found on this server!"
        echo -e " "
    fi
}

# Fungsi Unlock User
unlock_user() {
    read -p "Input username to UNLOCK: " username
    if id "$username" &>/dev/null; then
        passwd -u "$username" &>/dev/null
        clear
        echo -e " "
        echo -e "==============================================="
        echo -e " Username : ${blue}$username${NC}"
        echo -e " Status   : ${green}UNLOCKED${NC}"
        echo -e "-----------------------------------------------"
        echo -e " Login access for user ${blue}$username${NC} has been restored."
        echo -e "==============================================="
    else
        echo -e " "
        echo -e "${red}Error:${NC} Username '${yellow}$username${NC}' not found on this server!"
        echo -e " "
    fi
}

# Fungsi List Semua User
list_all_users() {
    echo -e " "
    echo -e "=========== ${yellow}ALL USERS${NC} ==========="
    awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd
    echo -e "==============================================="
}

# Fungsi List User yang Locked
list_locked_users() {
    echo -e " "
    echo -e "=========== ${red}LOCKED USERS${NC} ==========="
    passwd -S -a | awk '$2=="L" {print $1}'
    echo -e "==============================================="
}

# Fungsi List User yang Aktif
list_active_users() {
    echo -e " "
    echo -e "========== ${green}ACTIVE USERS${NC} ==========="
    passwd -S -a | awk '$2=="P" {print $1}'
    echo -e "==============================================="
}

# Menu Pilihan
while true; do
    clear
    echo -e "==============================================="
    echo -e "     ${yellow}SSH USER MANAGEMENT MENU${NC}"
    echo -e "==============================================="
    echo -e " 1) Lock User"
    echo -e " 2) Unlock User"
    echo -e " 3) List All Users"
    echo -e " 4) List Locked Users"
    echo -e " 5) List Active Users"
    echo -e " 0) Back To Menu"
    echo -e ""
    echo -e   "Press x or [ Ctrl+C ] • To-Exit"
    echo -e "==============================================="
    read -p "Choose an option [0-5]: " option
    echo -e " "

    case $option in
        1) lock_user ;;
        2) unlock_user ;;
        3) list_all_users ;;
        4) list_locked_users ;;
        5) list_active_users ;;
        0) clear ; exit ; m-sshovpn ;;
        x) exit ;;
        *) echo -e "${red}Invalid option!${NC}" ;;
    esac

    echo -e ""
    read -n 1 -s -r -p "Press any key to return to menu..."
done

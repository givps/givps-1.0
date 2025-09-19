#!/bin/bash
# Quick Setup | Script Setup Manager
# Edition : Stable Edition 1.1
# Author  : givps
# License : MIT
# (C) Copyright 2023
# =========================================

MYIP=$(wget -qO- ipv4.icanhazip.com)
echo "Checking VPS..."
clear

# Warna
RED="\033[0;31m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;41;36m                MEMBER SSH                 \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
printf "%-17s %-20s %-10s\n" "USERNAME" "EXP DATE" "STATUS"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# Loop akun dari /etc/passwd
while IFS=: read -r user _ uid _ _ _ _
do
    if [[ $uid -ge 1000 && "$user" != "nobody" ]]; then
        exp=$(chage -l "$user" | grep "Account expires" | awk -F": " '{print $2}')
        status=$(passwd -S "$user" | awk '{print $2}')

        if [[ "$status" == "L" ]]; then
            printf "%-17s %-20s ${RED}LOCKED${NC}\n" "$user" "$exp"
        else
            printf "%-17s %-20s ${GREEN}UNLOCKED${NC}\n" "$user" "$exp"
        fi
    fi
done < /etc/passwd

# Hitung jumlah akun
JUMLAH=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | wc -l)

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo "Total accounts : $JUMLAH user(s)"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

read -n 1 -s -r -p "Press any key to return to menu..."
m-sshovpn

#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition 1.1 (Fixed)
# Author  : givps
# License : MIT
# (C) Copyright 2023
# =========================================

MYIP=$(wget -qO- ipv4.icanhazip.com)
hariini=$(date +%d-%m-%Y)

clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m              ⇱ AUTO DELETE ⇲             \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"  
echo "Checking and removing expired users..."
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"  

# Prepare log files
ALLUSER_LOG="/usr/local/bin/alluser"
DELETED_LOG="/usr/local/bin/deleteduser"
: > "$ALLUSER_LOG"
: > "$DELETED_LOG"

# Read users from /etc/shadow
while IFS=: read -r username _ lastchg min max warn inactive expire rest; do
    # Skip system accounts (UID < 1000 usually not in /etc/shadow anyway)
    [[ -z "$max" || "$max" == "" ]] && continue

    # Expiry in seconds
    userexpireinseconds=$(( (lastchg + max) * 86400 ))
    tglexp=$(date -d @"$userexpireinseconds" +"%d %b %Y")
    todaystime=$(date +%s)

    # Format username to fixed width (15 chars)
    padded_user=$(printf "%-15s" "$username")

    # Log all users
    echo "Expired- User : $padded_user Expire at : $tglexp" >> "$ALLUSER_LOG"

    # If expired, delete user
    if (( userexpireinseconds < todaystime )); then
        echo "Expired- Username : $username expired at $tglexp, removed : $hariini" >> "$DELETED_LOG"
        echo "⚠️ User $username expired ($tglexp) → removed $hariini"
        userdel -r "$username" 2>/dev/null || true
    fi
done < /etc/shadow

echo -e "\n\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo "✅ Expired users cleanup done."
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

read -n 1 -s -r -p "Press any key to return to menu..."
m-sshovpn

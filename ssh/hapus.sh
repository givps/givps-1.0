#!/bin/bash
# =========================================
# Delete SSH User Script
# Edition : Stable Edition 1.1
# Author  : givps
# License : MIT
# (C) Copyright 2023
# =========================================

MYIP=$(wget -qO- ipv4.icanhazip.com)
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m              ⇱ DELETE SSH USER ⇲         \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""

# --- Ask for username ---
read -rp "🔑 Enter SSH Username to delete: " USERNAME

# --- Validate input ---
if [[ -z "$USERNAME" ]]; then
    echo -e "⚠️  Username cannot be empty!"
else
    if id "$USERNAME" &>/dev/null; then
        sudo userdel -r "$USERNAME" &>/dev/null
        echo -e "✅ User '$USERNAME' has been deleted successfully."
    else
        echo -e "❌ Error: User '$USERNAME' does not exist."
    fi
fi

echo ""
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -n 1 -s -r -p "Press any key to return to menu..."
m-sshovpn

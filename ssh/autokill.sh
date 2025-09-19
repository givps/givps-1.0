#!/bin/bash
# Quick Setup | Script Setup Manager
# Edition : Stable Edition 1.4 (English, autokick)
# Author  : givps
# License : MIT
# =========================================

MYIP=$(wget -qO- ipv4.icanhazip.com)
echo "Checking VPS..."
clear

# Colors
Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[ON]${Font_color_suffix}"
Error="${Red_font_prefix}[OFF]${Font_color_suffix}"

# Check autokill status
if grep -q "^# Autokill" /etc/cron.d/autokick 2>/dev/null; then
    sts="${Info}"
else
    sts="${Error}"
fi

clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m             AUTOKILL SSH          \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e " Autokill Status : $sts"
echo -e ""
echo -e "[1]  AutoKill After 5 Minutes"
echo -e "[2]  AutoKill After 10 Minutes"
echo -e "[3]  AutoKill After 15 Minutes"
echo -e "[4]  Turn Off AutoKill / MultiLogin"
echo -e "[5]  Custom Number Interval (Minutes)"
echo ""
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e ""

read -rp "Select an option [1-5 or Ctrl+C to exit]: " AutoKill
if [[ -z "$AutoKill" ]]; then
    echo -e "${Red_font_prefix}[Error]${Font_color_suffix} Input cannot be empty!"
    exit 1
fi

# For options 1–3 and 5, ask for max multi-login allowed
if [[ "$AutoKill" =~ ^[1-3]$|^5$ ]]; then
    read -rp "Maximum number of allowed multi-login sessions: " max
    if [[ -z "$max" || ! "$max" =~ ^[0-9]+$ ]]; then
        echo -e "${Red_font_prefix}[Error]${Font_color_suffix} Value must be a number!"
        exit 1
    fi
fi

case $AutoKill in
    1)
        clear
        echo "# Autokill" > /etc/cron.d/autokick
        echo "*/5 * * * * root /usr/bin/autokick $max" >> /etc/cron.d/autokick
        echo -e "\n======================================"
        echo -e " Allowed MultiLogin : $max"
        echo -e " AutoKill Interval  : 5 Minutes"
        echo -e "======================================\n"
        ;;
    2)
        clear
        echo "# Autokill" > /etc/cron.d/autokick
        echo "*/10 * * * * root /usr/bin/autokick $max" >> /etc/cron.d/autokick
        echo -e "\n======================================"
        echo -e " Allowed MultiLogin : $max"
        echo -e " AutoKill Interval  : 10 Minutes"
        echo -e "======================================\n"
        ;;
    3)
        clear
        echo "# Autokill" > /etc/cron.d/autokick
        echo "*/15 * * * * root /usr/bin/autokick $max" >> /etc/cron.d/autokick
        echo -e "\n======================================"
        echo -e " Allowed MultiLogin : $max"
        echo -e " AutoKill Interval  : 15 Minutes"
        echo -e "======================================\n"
        ;;
    4)
        clear
        rm -f /etc/cron.d/autokick
        echo -e "\n======================================"
        echo -e " AutoKill MultiLogin is Disabled"
        echo -e "======================================\n"
        ;;
    5)
        read -rp "Enter custom number interval (minutes): " interval
        if [[ -z "$interval" || ! "$interval" =~ ^[0-9]+$ ]]; then
            echo -e "${Red_font_prefix}[Error]${Font_color_suffix} Interval must be a number!"
            exit 1
        fi
        clear
        echo "# Autokill" > /etc/cron.d/autokick
        echo "*/$interval * * * * root /usr/bin/autokick $max" >> /etc/cron.d/autokick
        echo -e "\n======================================"
        echo -e " Allowed MultiLogin : $max"
        echo -e " AutoKill Interval  : $interval Minutes"
        echo -e "======================================\n"
        ;;
    *)
        echo -e "${Red_font_prefix}[Error]${Font_color_suffix} Invalid option!"
        m-sshovpn 1
        ;;
esac

# Restart cron service
systemctl restart cron >/dev/null 2>&1

echo -e "${Green_font_prefix}[OK]${Font_color_suffix} Autokill setting applied successfully!"

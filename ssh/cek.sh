#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition 1.2 (English)
# Author  : givps
# License : MIT
# (C) Copyright 2023
# =========================================

MYIP=$(wget -qO- ipv4.icanhazip.com)
echo "Checking VPS..."
clear
echo " "

# Detect log file
if [ -e "/var/log/auth.log" ]; then
    LOG="/var/log/auth.log"
elif [ -e "/var/log/secure" ]; then
    LOG="/var/log/secure"
else
    echo "No authentication log file found!"
    exit 1
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DROPBEAR LOGIN
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pids=( $(ps aux | grep -i dropbear | awk '{print $2}') )
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;41;36m          Active Dropbear Logins         \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo "PID  |  Username  |  IP Address"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

grep -i "dropbear" "$LOG" | grep -i "Password auth succeeded" > /tmp/login-db.txt
for PID in "${pids[@]}"; do
    grep "dropbear\[$PID\]" /tmp/login-db.txt > /tmp/login-db-pid.txt
    if [ -s /tmp/login-db-pid.txt ]; then
        USER=$(awk '{print $10}' /tmp/login-db-pid.txt | head -n1)
        IP=$(awk '{print $12}' /tmp/login-db-pid.txt | head -n1)
        echo "$PID  |  $USER  |  $IP"
    fi
done
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo " "

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# OPENSSH LOGIN
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;41;36m          Active OpenSSH Logins          \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo "PID  |  Username  |  IP Address"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

grep -i "sshd" "$LOG" | grep -i "Accepted password for" > /tmp/login-ssh.txt
pids=( $(ps aux | grep "\[priv\]" | awk '{print $2}') )
for PID in "${pids[@]}"; do
    grep "sshd\[$PID\]" /tmp/login-ssh.txt > /tmp/login-ssh-pid.txt
    if [ -s /tmp/login-ssh-pid.txt ]; then
        USER=$(awk '{print $9}' /tmp/login-ssh-pid.txt | head -n1)
        IP=$(awk '{print $11}' /tmp/login-ssh-pid.txt | head -n1)
        echo "$PID  |  $USER  |  $IP"
    fi
done
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo " "

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# OPENVPN TCP LOGIN
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if [ -f "/etc/openvpn/server/openvpn-tcp.log" ]; then
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[0;41;36m          Active OpenVPN TCP Logins       \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo "Username  |  IP Address  |  Connected Since"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    grep -w "^CLIENT_LIST" /etc/openvpn/server/openvpn-tcp.log \
        | cut -d ',' -f 2,3,8 \
        | sed -e 's/,/      /g'
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# OPENVPN UDP LOGIN
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if [ -f "/etc/openvpn/server/openvpn-udp.log" ]; then
    echo " "
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[0;41;36m          Active OpenVPN UDP Logins       \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo "Username  |  IP Address  |  Connected Since"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    grep -w "^CLIENT_LIST" /etc/openvpn/server/openvpn-udp.log \
        | cut -d ',' -f 2,3,8 \
        | sed -e 's/,/      /g'
fi
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""

# Cleanup temp files
rm -f /tmp/login-db.txt /tmp/login-db-pid.txt
rm -f /tmp/login-ssh.txt /tmp/login-ssh-pid.txt

read -n 1 -s -r -p "Press any key to return to menu..."

m-sshovpn

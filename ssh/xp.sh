#!/bin/bash
# Quick Setup | Script Setup Manager
# Edition : Stable Edition 1.0
# Author  : givps
# The MIT License (MIT)
# (C) Copyright 2023
# =========================================

LOG_FILE="/var/log/autoremove.log"
MYIP=$(wget -qO- ipv4.icanhazip.com)
echo "[$(date)] Starting auto-remove on VPS $MYIP" | tee -a $LOG_FILE
clear
now=$(date +"%Y-%m-%d")

# ============= Auto Remove Vmess =============
users_vmess=$(grep '^### ' /etc/xray/config.json | awk '{print $2}' | sort -u)
for user in $users_vmess; do
    exp=$(grep -w "^### $user" /etc/xray/config.json | awk '{print $3}')
    [[ -z "$exp" ]] && continue
    d1=$(date -d "$exp" +%s)
    d2=$(date -d "$now" +%s)
    exp2=$(( (d1 - d2) / 86400 ))
    if [[ $exp2 -le 0 ]]; then
        sed -i "/^### $user $exp/,/^},{/d" /etc/xray/config.json
        rm -f /etc/xray/$user-tls.json /etc/xray/$user-none.json
        echo "[$(date)] Deleted expired Vmess user: $user (expired $exp)" | tee -a $LOG_FILE
    fi
done

# ============= Auto Remove Vless =============
users_vless=$(grep '^#& ' /etc/xray/config.json | awk '{print $2}' | sort -u)
for user in $users_vless; do
    exp=$(grep -w "^#& $user" /etc/xray/config.json | awk '{print $3}')
    [[ -z "$exp" ]] && continue
    d1=$(date -d "$exp" +%s)
    d2=$(date -d "$now" +%s)
    exp2=$(( (d1 - d2) / 86400 ))
    if [[ $exp2 -le 0 ]]; then
        sed -i "/^#& $user $exp/,/^},{/d" /etc/xray/config.json
        echo "[$(date)] Deleted expired Vless user: $user (expired $exp)" | tee -a $LOG_FILE
    fi
done

# ============= Auto Remove Trojan =============
users_trojan=$(grep '^#! ' /etc/xray/config.json | awk '{print $2}' | sort -u)
for user in $users_trojan; do
    exp=$(grep -w "^#! $user" /etc/xray/config.json | awk '{print $3}')
    [[ -z "$exp" ]] && continue
    d1=$(date -d "$exp" +%s)
    d2=$(date -d "$now" +%s)
    exp2=$(( (d1 - d2) / 86400 ))
    if [[ $exp2 -le 0 ]]; then
        sed -i "/^#! $user $exp/,/^},{/d" /etc/xray/config.json
        echo "[$(date)] Deleted expired Trojan user: $user (expired $exp)" | tee -a $LOG_FILE
    fi
done

# Restart Xray setelah perubahan
systemctl restart xray
echo "[$(date)] Restarted Xray service" | tee -a $LOG_FILE

# ============= Auto Remove SSH =============
today=$(date +%s)
while IFS=: read -r username _ _ _ _ _ _ expire; do
    [[ -z "$expire" || "$expire" == "" ]] && continue
    expire_seconds=$((expire * 86400))
    if [[ $expire_seconds -lt $today ]]; then
        userdel --force "$username" 2>/dev/null
        echo "[$(date)] Deleted expired SSH user: $username" | tee -a $LOG_FILE
    fi
done < /etc/shadow

echo "[$(date)] Auto-remove process completed." | tee -a $LOG_FILE

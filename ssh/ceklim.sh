#!/bin/bash
# =========================================
# SSH, Dropbear & OpenVPN Manager
# Author  : givps
# License : MIT
# =========================================

MYIP=$(wget -qO- ipv4.icanhazip.com);

clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;41;36m           SSH & VPN MENU          \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e " [1] Check Active SSH/Dropbear/OpenVPN Logins"
echo -e " [2] Check User Multi-Login Violations"
echo -e " [x] Exit"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
read -p "Select menu [1-2 or x]: " opt

case $opt in
    1)
        clear
        echo "Checking VPS: $MYIP"
        echo " "

        # Detect log file
        if [ -e "/var/log/auth.log" ]; then
            LOG="/var/log/auth.log"
        elif [ -e "/var/log/secure" ]; then
            LOG="/var/log/secure"
        else
            echo "Log file not found!"
            exit 1
        fi

        # -------- Dropbear --------
        data=( $(ps aux | grep -i dropbear | awk '{print $2}') )
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo -e "\E[0;41;36m          Dropbear User Login       \E[0m"
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo "PID  |  Username  |  IP Address"
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        grep -i dropbear "$LOG" | grep -i "Password auth succeeded" > /tmp/login-db.txt
        for PID in "${data[@]}"; do
            grep "dropbear\[$PID\]" /tmp/login-db.txt > /tmp/login-db-pid.txt
            NUM=$(wc -l < /tmp/login-db-pid.txt)
            USER=$(awk '{print $10}' /tmp/login-db-pid.txt)
            IP=$(awk '{print $12}' /tmp/login-db-pid.txt)
            if [ "$NUM" -eq 1 ]; then
                echo "$PID - $USER - $IP"
            fi
        done
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo " "

        # -------- OpenSSH --------
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo -e "\E[0;41;36m           OpenSSH User Login       \E[0m"
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo "PID  |  Username  |  IP Address"
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        grep -i sshd "$LOG" | grep -i "Accepted password for" > /tmp/login-ssh.txt
        data=( $(ps aux | grep "\[priv\]" | awk '{print $2}') )
        for PID in "${data[@]}"; do
            grep "sshd\[$PID\]" /tmp/login-ssh.txt > /tmp/login-ssh-pid.txt
            NUM=$(wc -l < /tmp/login-ssh-pid.txt)
            USER=$(awk '{print $9}' /tmp/login-ssh-pid.txt)
            IP=$(awk '{print $11}' /tmp/login-ssh-pid.txt)
            if [ "$NUM" -eq 1 ]; then
                echo "$PID - $USER - $IP"
            fi
        done
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo " "

        # -------- OpenVPN TCP --------
        if [ -f "/etc/openvpn/server/openvpn-tcp.log" ]; then
            echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
            echo -e "\E[0;41;36m          OpenVPN TCP User Login         \E[0m"
            echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
            echo "Username  |  IP Address  |  Connected Since"
            echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
            grep -w "^CLIENT_LIST" /etc/openvpn/server/openvpn-tcp.log | cut -d ',' -f 2,3,8 | sed -e 's/,/      /g'
            echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
            echo " "
        fi

        # -------- OpenVPN UDP --------
        if [ -f "/etc/openvpn/server/openvpn-udp.log" ]; then
            echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
            echo -e "\E[0;41;36m          OpenVPN UDP User Login         \E[0m"
            echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
            echo "Username  |  IP Address  |  Connected Since"
            echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
            grep -w "^CLIENT_LIST" /etc/openvpn/server/openvpn-udp.log | cut -d ',' -f 2,3,8 | sed -e 's/,/      /g'
            echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
            echo " "
        fi

        # Cleanup
        rm -f /tmp/login-db.txt /tmp/login-db-pid.txt /tmp/login-ssh.txt /tmp/login-ssh-pid.txt
        read -n 1 -s -r -p "Press any key to return to menu"
        $0
    ;;
    2)
        clear
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo -e "\E[0;41;36m       CHECK MULTI-LOGIN USERS     \E[0m"
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        if [ -e "/root/log-limit.txt" ]; then
            echo "User Violating Maximum Limit:"
            echo "Time - Username - Number of Logins"
            echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
            cat /root/log-limit.txt
        else
            echo "No users have violated the login limit."
            echo "Or the limit script has not been executed."
        fi
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        read -n 1 -s -r -p "Press any key to return to menu"
        $0
    ;;
    x)
        clear
        m-sshovpn
    ;;
    *)
        echo "Invalid option"
        sleep 1
        $0
    ;;
esac

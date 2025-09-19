#!/bin/bash
# =========================================
# SSH/Dropbear AutoKill - Limit Multi Login
# Auto Install + Auto CronJob
# Edition : Stable Edition 1.2
# Author  : givps
# License : MIT
# =========================================

# Default max login per user
MAX=1

# Location file autokill
SCRIPT_PATH="/usr/local/bin/autokill"

# Create main script
cat > $SCRIPT_PATH << 'EOF'
#!/bin/bash
MAX=1
MYIP=$(wget -qO- ipv4.icanhazip.com)
DATE=$(date +"%Y-%m-%d %X")

if [ -e "/var/log/auth.log" ]; then
    OS=1
    LOG="/var/log/auth.log"
elif [ -e "/var/log/secure" ]; then
    OS=2
    LOG="/var/log/secure"
else
    echo "$DATE - No authentication log found!" >> /root/log-limit.txt
    exit 1
fi

awk -F: '/\/home\// {print $1}' /etc/passwd > /root/user.txt
mapfile -t USERS < /root/user.txt

declare -A COUNT
declare -A PIDLIST

grep -i dropbear "$LOG" | grep -i "Password auth succeeded" > /tmp/log-db.txt
for PID in $(pgrep dropbear); do
    if grep "dropbear\[$PID\]" /tmp/log-db.txt >/dev/null; then
        USER=$(grep "dropbear\[$PID\]" /tmp/log-db.txt | awk '{print $10}' | tr -d "'")
        if [[ " ${USERS[*]} " =~ " ${USER} " ]]; then
            COUNT[$USER]=$((COUNT[$USER]+1))
            PIDLIST[$USER]="${PIDLIST[$USER]} $PID"
        fi
    fi
done

grep -i sshd "$LOG" | grep -i "Accepted password for" > /tmp/log-ssh.txt
for PID in $(pgrep -f "sshd:.*@"); do
    if grep "sshd\[$PID\]" /tmp/log-ssh.txt >/dev/null; then
        USER=$(grep "sshd\[$PID\]" /tmp/log-ssh.txt | awk '{print $9}')
        if [[ " ${USERS[*]} " =~ " ${USER} " ]]; then
            COUNT[$USER]=$((COUNT[$USER]+1))
            PIDLIST[$USER]="${PIDLIST[$USER]} $PID"
        fi
    fi
done

KILLED=0
for USER in "${!COUNT[@]}"; do
    if [ "${COUNT[$USER]}" -gt "$MAX" ]; then
        echo "$DATE - $USER - ${COUNT[$USER]} sessions killed" | tee -a /root/log-limit.txt
        kill ${PIDLIST[$USER]}
        KILLED=$((KILLED+1))
    fi
done

if [ $KILLED -gt 0 ]; then
    if [ $OS -eq 1 ]; then
        service ssh restart >/dev/null 2>&1
    else
        service sshd restart >/dev/null 2>&1
    fi
    service dropbear restart >/dev/null 2>&1
fi
EOF

# Set permission
chmod +x $SCRIPT_PATH

# Add to cron if not exists
if ! grep -q "$SCRIPT_PATH" /etc/crontab; then
    echo "* * * * * root $SCRIPT_PATH" >> /etc/crontab
fi

# Restart cron
service cron restart

clear
echo "========================================="
echo " AutoKill SSH/Dropbear installed"
echo " Location script : $SCRIPT_PATH"
echo " CronJob         : Every 1 minute"
echo " Max Login/User  : $MAX"
echo " Log file        : /root/log-limit.txt"
echo "========================================="

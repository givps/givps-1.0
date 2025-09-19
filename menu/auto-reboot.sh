#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition 1.0
# Author  : givps
# The MIT License (MIT)
# (C) Copyright 2023
# =========================================

# Pewarna hidup
BRed='\e[1;31m'
BGreen='\e[1;32m'
BYellow='\e[1;33m'
BBlue='\e[1;34m'
BPurple='\e[1;35m'
NC='\e[0m'

# Ambil IP
MYIP=$(wget -qO- ipv4.icanhazip.com)
echo "Checking VPS..."
sleep 1
clear

# Buat script auto reboot jika belum ada
if [ ! -e /usr/local/bin/reboot_otomatis ]; then
    cat > /usr/local/bin/reboot_otomatis <<-EOF
#!/bin/bash
tanggal=\$(date +"%m-%d-%Y")
waktu=\$(date +"%T")
echo "Server successfully rebooted on \$tanggal at \$waktu." >> /root/log-reboot.txt
/sbin/shutdown -r now
EOF
    chmod +x /usr/local/bin/reboot_otomatis
fi

# Tampilan menu
echo -e "${BYellow} -------------------------------------------------${NC}"
echo -e "${BBlue}                 AUTO-REBOOT MENU                 ${NC}"
echo -e "${BYellow} -------------------------------------------------${NC}"
echo -e ""
echo -e "${BPurple} 1 ${NC} Set Auto-Reboot Every 1 Hour"
echo -e "${BPurple} 2 ${NC} Set Auto-Reboot Every 6 Hours"
echo -e "${BPurple} 3 ${NC} Set Auto-Reboot Every 12 Hours"
echo -e "${BPurple} 4 ${NC} Set Auto-Reboot Every 1 Day"
echo -e "${BPurple} 5 ${NC} Set Auto-Reboot Every 1 Week"
echo -e "${BPurple} 6 ${NC} Set Auto-Reboot Every 1 Month"
echo -e "${BPurple} 7 ${NC} Turn Off Auto-Reboot"
echo -e "${BPurple} 8 ${NC} View Reboot Log"
echo -e "${BPurple} 9 ${NC} Clear Reboot Log"
echo -e ""
echo -e "${BPurple} 0 ${NC} Back To Menu"
echo -e ""
echo -e "${BBlue} Press x or [Ctrl+C] to Exit ${NC}"
echo -e ""
echo -e "${BYellow} -------------------------------------------------${NC}"
echo -e ""

read -p " Select menu : " opt
clear

case $opt in
1)
    echo "0 * * * * root /usr/local/bin/reboot_otomatis" > /etc/cron.d/reboot_otomatis
    echo -e "[${BGreen}OK${NC}] Auto-Reboot set every 1 hour."
    ;;
2)
    echo "0 */6 * * * root /usr/local/bin/reboot_otomatis" > /etc/cron.d/reboot_otomatis
    echo -e "[${BGreen}OK${NC}] Auto-Reboot set every 6 hours."
    ;;
3)
    echo "0 */12 * * * root /usr/local/bin/reboot_otomatis" > /etc/cron.d/reboot_otomatis
    echo -e "[${BGreen}OK${NC}] Auto-Reboot set every 12 hours."
    ;;
4)
    echo "0 0 * * * root /usr/local/bin/reboot_otomatis" > /etc/cron.d/reboot_otomatis
    echo -e "[${BGreen}OK${NC}] Auto-Reboot set once a day."
    ;;
5)
    echo "0 0 * * 0 root /usr/local/bin/reboot_otomatis" > /etc/cron.d/reboot_otomatis
    echo -e "[${BGreen}OK${NC}] Auto-Reboot set once a week."
    ;;
6)
    echo "0 0 1 * * root /usr/local/bin/reboot_otomatis" > /etc/cron.d/reboot_otomatis
    echo -e "[${BGreen}OK${NC}] Auto-Reboot set once a month."
    ;;
7)
    rm -f /etc/cron.d/reboot_otomatis
    echo -e "[${BGreen}OK${NC}] Auto-Reboot disabled."
    ;;
8)
    echo -e "${BYellow} ----------------- REBOOT LOG --------------------${NC}"
    if [ -e /root/log-reboot.txt ]; then
        cat /root/log-reboot.txt
    else
        echo "No reboot activity found."
    fi
    echo -e "${BYellow} -------------------------------------------------${NC}"
    read -n 1 -s -r -p "Press any key to return..."
    auto-reboot
    ;;
9)
    echo "" > /root/log-reboot.txt
    echo -e "[${BGreen}OK${NC}] Reboot log cleared."
    read -n 1 -s -r -p "Press any key to return..."
    auto-reboot
    ;;
0)
    m-system
    ;;
x)
    exit
    ;;
*)
    echo -e "[${BRed}ERROR${NC}] Invalid option!"
    sleep 1
    auto-reboot
    ;;
esac

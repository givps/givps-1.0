#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition 1.0
# Author  : givps
# The MIT License (MIT)
# (C) Copyright 2023
# =========================================

# Pewarna hidup
BGreen='\e[1;32m'
BYellow='\e[1;33m'
BBlue='\e[1;34m'
BPurple='\e[1;35m'
NC='\e[0m'

# Ambil IP VPS
MYIP=$(wget -qO- ipv4.icanhazip.com)

clear
echo -e "${BYellow} -------------------------------------------------${NC}"
echo -e "${BBlue}                BANDWIDTH MONITOR                 ${NC}"
echo -e "${BYellow} -------------------------------------------------${NC}"
echo -e ""
echo -e "${BPurple} 1 ${NC} View Total Remaining Bandwidth"
echo -e "${BPurple} 2 ${NC} Usage Table Every 5 Minutes"
echo -e "${BPurple} 3 ${NC} Hourly Usage Table"
echo -e "${BPurple} 4 ${NC} Daily Usage Table"
echo -e "${BPurple} 5 ${NC} Monthly Usage Table"
echo -e "${BPurple} 6 ${NC} Annual Usage Table"
echo -e "${BPurple} 7 ${NC} Highest Usage Table"
echo -e "${BPurple} 8 ${NC} Hourly Usage Statistics"
echo -e "${BPurple} 9 ${NC} View Current Active Usage"
echo -e "${BPurple} 10 ${NC} View Current Active Usage Traffic [5s]"
echo -e ""
echo -e "${BBlue} 0 Back To Menu ${NC}"
echo -e "${BBlue} x Exit ${NC}"
echo -e ""
echo -e "${BYellow} -------------------------------------------------${NC}"
echo -e ""

read -p " Select menu : " opt
echo -e ""

case $opt in
1)
    clear
    echo -e "${BYellow} -------------------------------------------------${NC}"
    echo -e "${BBlue}          TOTAL SERVER BANDWIDTH REMAINING        ${NC}"
    echo -e "${BYellow} -------------------------------------------------${NC}"
    echo -e ""
    vnstat
    echo -e ""
    echo -e "${BYellow} -------------------------------------------------${NC}"
    echo -e ""
    read -n 1 -s -r -p "Press any key to return..."
    bw
    ;;
2)
    clear
    echo -e "${BYellow} -------------------------------------------------${NC}"
    echo -e "${BBlue}           TOTAL BANDWIDTH EVERY 5 MINUTES        ${NC}"
    echo -e "${BYellow} -------------------------------------------------${NC}"
    echo -e ""
    vnstat -5
    echo -e ""
    echo -e "${BYellow} -------------------------------------------------${NC}"
    echo -e ""
    read -n 1 -s -r -p "Press any key to return..."
    bw
    ;;
3)
    clear
    echo -e "${BYellow} -------------------------------------------------${NC}"
    echo -e "${BBlue}                HOURLY BANDWIDTH                  ${NC}"
    echo -e "${BYellow} -------------------------------------------------${NC}"
    echo -e ""
    vnstat -h
    echo -e ""
    echo -e "${BYellow} -------------------------------------------------${NC}"
    echo -e ""
    read -n 1 -s -r -p "Press any key to return..."
    bw
    ;;
4)
    clear
    echo -e "${BYellow} -------------------------------------------------${NC}"
    echo -e "${BBlue}                  DAILY BANDWIDTH                 ${NC}"
    echo -e "${BYellow} -------------------------------------------------${NC}"
    echo -e ""
    vnstat -d
    echo -e ""
    echo -e "${BYellow} -------------------------------------------------${NC}"
    echo -e ""
    read -n 1 -s -r -p "Press any key to return..."
    bw
    ;;
5)
    clear
    echo -e "${BYellow} -------------------------------------------------${NC}"
    echo -e "${BBlue}                 MONTHLY BANDWIDTH                ${NC}"
    echo -e "${BYellow} -------------------------------------------------${NC}"
    echo -e ""
    vnstat -m
    echo -e ""
    echo -e "${BYellow} -------------------------------------------------${NC}"
    echo -e ""
    read -n 1 -s -r -p "Press any key to return..."
    bw
    ;;
6)
    clear
    echo -e "${BYellow} -------------------------------------------------${NC}"
    echo -e "${BBlue}                  YEARLY BANDWIDTH                ${NC}"
    echo -e "${BYellow} -------------------------------------------------${NC}"
    echo -e ""
    vnstat -y
    echo -e ""
    echo -e "${BYellow} -------------------------------------------------${NC}"
    echo -e ""
    read -n 1 -s -r -p "Press any key to return..."
    bw
    ;;
7)
    clear
    echo -e "${BYellow} -------------------------------------------------${NC}"
    echo -e "${BBlue}                HIGHEST BANDWIDTH USAGE           ${NC}"
    echo -e "${BYellow} -------------------------------------------------${NC}"
    echo -e ""
    vnstat -t
    echo -e ""
    echo -e "${BYellow} -------------------------------------------------${NC}"
    echo -e ""
    read -n 1 -s -r -p "Press any key to return..."
    bw
    ;;
8)
    clear
    echo -e "${BYellow} -------------------------------------------------${NC}"
    echo -e "${BBlue}              HOURLY USAGE STATISTICS             ${NC}"
    echo -e "${BYellow} -------------------------------------------------${NC}"
    echo -e ""
    vnstat -hg
    echo -e ""
    echo -e "${BYellow} -------------------------------------------------${NC}"
    echo -e ""
    read -n 1 -s -r -p "Press any key to return..."
    bw
    ;;
9)
    clear
    echo -e "${BYellow} -------------------------------------------------${NC}"
    echo -e "${BBlue}              CURRENT LIVE BANDWIDTH              ${NC}"
    echo -e "${BYellow} -------------------------------------------------${NC}"
    echo -e "${BBlue} Press [ Ctrl+C ] To Exit ${NC}"
    echo -e ""
    vnstat -l
    echo -e ""
    echo -e "${BYellow} -------------------------------------------------${NC}"
    echo -e ""
    read -n 1 -s -r -p "Press any key to return..."
    bw
    ;;
10)
    clear
    echo -e "${BYellow} -------------------------------------------------${NC}"
    echo -e "${BBlue}             LIVE BANDWIDTH TRAFFIC [5s]          ${NC}"
    echo -e "${BYellow} -------------------------------------------------${NC}"
    echo -e ""
    vnstat -tr
    echo -e ""
    echo -e "${BYellow} -------------------------------------------------${NC}"
    echo -e ""
    read -n 1 -s -r -p "Press any key to return..."
    bw
    ;;
0)
    sleep 1
    m-system
    ;;
x)
    exit
    ;;
*)
    echo -e ""
    echo -e "${BRed} Invalid option, please try again... ${NC}"
    sleep 1
    bw
    ;;
esac

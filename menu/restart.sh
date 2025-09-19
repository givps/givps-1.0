#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition 1.0
# Author  : givps
# The MIT License (MIT)
# (C) Copyright 2023
# =========================================

MYIP=$(wget -qO- ipv4.icanhazip.com)
clear

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
NC='\033[0m'

show_header() {
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "\E[0;100;33m         • RESTART MENU •          \E[0m"
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
}

show_menu() {
  echo -e " [${CYAN}1${NC}] Restart All Services"
  echo -e " [${CYAN}2${NC}] Restart OpenSSH"
  echo -e " [${CYAN}3${NC}] Restart Dropbear"
  echo -e " [${CYAN}4${NC}] Restart Stunnel4"
  echo -e " [${CYAN}5${NC}] Restart OpenVPN"
  echo -e " [${CYAN}6${NC}] Restart Squid"
  echo -e " [${CYAN}7${NC}] Restart Nginx"
  echo -e " [${CYAN}8${NC}] Restart Badvpn"
  echo -e " [${CYAN}9${NC}] Restart Xray"
  echo -e " [${CYAN}10${NC}] Restart Websocket"
  echo -e " [${CYAN}11${NC}] Restart Trojan"
  echo ""
  echo -e " [${RED}0${NC}] Back To Menu"
  echo -e " [x] Exit"
  echo ""
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
}

restart_msg() {
  echo -e "[ ${GREEN}OK${NC} ] $1 restarted"
}

# Main
show_header
show_menu
read -p " Select menu : " opt
clear

case $opt in
  1)
    show_header
    echo "[INFO] Restarting all services..."
    sleep 1
    /etc/init.d/ssh restart && restart_msg "OpenSSH"
    /etc/init.d/dropbear restart && restart_msg "Dropbear"
    /etc/init.d/stunnel4 restart && restart_msg "Stunnel4"
    /etc/init.d/openvpn restart && restart_msg "OpenVPN"
    /etc/init.d/fail2ban restart && restart_msg "Fail2Ban"
    /etc/init.d/cron restart && restart_msg "Cron"
    /etc/init.d/nginx restart && restart_msg "Nginx"
    /etc/init.d/squid restart && restart_msg "Squid"
    systemctl restart xray && restart_msg "Xray"
    screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 500
    screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 500
    screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500
    restart_msg "Badvpn"
    systemctl restart sshws.service ws-dropbear.service ws-stunnel.service
    restart_msg "Websocket"
    systemctl restart trojan-go.service
    restart_msg "Trojan"
    echo ""
    echo "[INFO] All services restarted!"
    ;;
  2) /etc/init.d/ssh restart && restart_msg "OpenSSH" ;;
  3) /etc/init.d/dropbear restart && restart_msg "Dropbear" ;;
  4) /etc/init.d/stunnel4 restart && restart_msg "Stunnel4" ;;
  5) /etc/init.d/openvpn restart && restart_msg "OpenVPN" ;;
  6) /etc/init.d/squid restart && restart_msg "Squid" ;;
  7) /etc/init.d/nginx restart && restart_msg "Nginx" ;;
  8) screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500 && restart_msg "Badvpn" ;;
  9) systemctl restart xray && restart_msg "Xray" ;;
  10) systemctl restart sshws.service ws-dropbear.service ws-stunnel.service && restart_msg "Websocket" ;;
  11) systemctl restart trojan-go.service && restart_msg "Trojan" ;;
  0) m-system ; exit ;;
  x) exit ;;
  *) echo "Invalid option!" ; sleep 1 ;;
esac

echo ""
read -n 1 -s -r -p "Press any key to return to system menu"
restart

#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition 1.0
# Author  : givps
# The MIT License (MIT)
# (C) Copyright 2023
# =========================================

BGreen='\e[1;32m'
BRed='\e[1;31m'
NC='\e[0m'

clear
cd

echo -e "${BGreen}==> Installing Websocket-SSH Python services...${NC}"

# Download Python WebSocket scripts
echo -e "${BGreen}[1/4] Downloading ws-dropbear...${NC}"
wget -q -O /usr/local/bin/ws-dropbear https://raw.githubusercontent.com/givps/AutoScriptXray/master/sshws/ws-dropbear \
  || { echo -e "${BRed}Failed to download ws-dropbear${NC}"; exit 1; }

echo -e "${BGreen}[2/4] Downloading ws-stunnel...${NC}"
wget -q -O /usr/local/bin/ws-stunnel https://raw.githubusercontent.com/givps/AutoScriptXray/master/sshws/ws-stunnel \
  || { echo -e "${BRed}Failed to download ws-stunnel${NC}"; exit 1; }

# Set executable permission
chmod +x /usr/local/bin/ws-dropbear
chmod +x /usr/local/bin/ws-stunnel

# Download systemd service files
echo -e "${BGreen}[3/4] Setting up systemd service for ws-dropbear...${NC}"
wget -q -O /etc/systemd/system/ws-dropbear.service https://raw.githubusercontent.com/givps/AutoScriptXray/master/sshws/ws-dropbear.service \
  || { echo -e "${BRed}Failed to download ws-dropbear.service${NC}"; exit 1; }

echo -e "${BGreen}[4/4] Setting up systemd service for ws-stunnel...${NC}"
wget -q -O /etc/systemd/system/ws-stunnel.service https://raw.githubusercontent.com/givps/AutoScriptXray/master/sshws/ws-stunnel.service \
  || { echo -e "${BRed}Failed to download ws-stunnel.service${NC}"; exit 1; }

# Reload systemd
systemctl daemon-reload

# Enable & Restart services
systemctl daemon-reload
systemctl enable ws-dropbear
systemctl restart ws-dropbear
systemctl status ws-dropbear
systemctl enable ws-dropbear.service
systemctl restart ws-dropbear.service

systemctl daemon-reload
systemctl enable ws-stunnel
systemctl restart ws-stunnel
systemctl status ws-stunnel
systemctl enable ws-stunnel.service
systemctl restart ws-stunnel.service
clear
echo -e "${BGreen}==> Installation completed!${NC}"
echo ""
echo -e "${BGreen}=== Service Status ===${NC}"

systemctl --no-pager status ws-dropbear.service | sed -n '1,5p'
systemctl --no-pager status ws-stunnel.service | sed -n '1,5p'

echo ""
echo -e "${BGreen}=== Last 10 logs (Dropbear WebSocket) ===${NC}"
journalctl -u ws-dropbear.service -n 10 --no-pager

echo ""
echo -e "${BGreen}=== Last 10 logs (Stunnel WebSocket) ===${NC}"
journalctl -u ws-stunnel.service -n 10 --no-pager
echo -e "${BGreen}=== Continue in 5s ===${NC}"
sleep 5
clear
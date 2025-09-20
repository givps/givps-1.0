#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition 1.1 (Improved)
# Author  : givps
# License : MIT
# =========================================

# --- Colors ---
red='\e[1;31m'; green='\e[0;32m'; yellow='\e[1;33m'; blue='\e[1;34m'; nc='\e[0m'

# --- Root Check ---
if [ "${EUID}" -ne 0 ]; then
    echo -e "${red}You need to run this script as root${nc}"
    exit 1
fi

# --- Virtualization Check ---
if [ "$(systemd-detect-virt)" == "openvz" ]; then
    echo -e "${red}OpenVZ is not supported.${nc}"
    echo "Please use KVM/VMware based VPS."
    exit 1
fi

# --- Host Fix ---
localip=$(hostname -I | awk '{print $1}')
hostname_current=$(hostname)
if ! grep -q "$hostname_current" /etc/hosts; then
    echo "$localip $hostname_current" >> /etc/hosts
fi

# --- Folder Preparation ---
mkdir -p /etc/xray /etc/v2ray
touch /etc/xray/{domain,scdomain}
touch /etc/v2ray/{domain,scdomain}

# --- Kernel Headers Check ---
kernel_version=$(uname -r)
headers_pkg="linux-headers-$kernel_version"
if ! dpkg -s "$headers_pkg" >/dev/null 2>&1; then
    echo -e "${yellow}Installing missing package: $headers_pkg${nc}"
    apt-get update && apt-get install -y "$headers_pkg" || {
        echo -e "${red}Failed to install kernel headers. Please run manually:${nc}"
        echo "apt update && apt upgrade -y && reboot"
        exit 1
    }
fi

# --- Timezone & IPv6 ---
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1

# --- Basic Tools ---
apt install -y git curl wget python3 socat >/dev/null 2>&1

# --- Domain Setup ---
clear
echo -e "${blue}================ VPS DOMAIN SETUP ================${nc}"
echo "1) Use Random Domain (Cloudflare API)"
echo "2) Use Your Own Domain"
read -rp "Choose [1/2]: " dns

if [[ "$dns" == "1" ]]; then
    wget -q https://raw.githubusercontent.com/givps/givps-1.0/master/ssh/cf \
      -O /root/cf && chmod +x /root/cf && bash /root/cf
elif [[ "$dns" == "2" ]]; then
    read -rp "Enter Your Domain : " dom
    echo "$dom" | tee /root/domain /root/scdomain /etc/xray/{domain,scdomain} /etc/v2ray/{domain,scdomain} >/dev/null
    echo "IP=$dom" > /var/lib/ipvps.conf
else
    echo -e "${red}Invalid choice.${nc}"
    exit 1
fi

# --- Install Nginx + TLS ---
apt install -y nginx certbot python3-certbot-nginx
systemctl enable --now nginx

domain=$(cat /root/domain)
echo -e "${green}Installing SSL Certificate for $domain...${nc}"
certbot --nginx --non-interactive --agree-tos -m admin@$domain -d $domain || {
    echo -e "${red}Certbot failed. Please check your domain DNS.${nc}"
}

# --- Install Services ---
wget -q https://raw.githubusercontent.com/givps/givps-1.0/master/ssh/ssh-vpn.sh \
  -O /root/ssh-vpn.sh && chmod +x /root/ssh-vpn.sh && bash /root/ssh-vpn.sh

wget -q https://raw.githubusercontent.com/givps/givps-1.0/master/xray/ins-xray.sh \
  -O /root/ins-xray.sh && chmod +x /root/ins-xray.sh && bash /root/ins-xray.sh

wget -q https://raw.githubusercontent.com/givps/givps-1.0/master/sshws/insshws.sh \
  -O /root/insshws.sh && chmod +x /root/insshws.sh && bash /root/insshws.sh

# --- Auto Profile ---
cat > /root/.profile <<'END'
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
clear
menu
END

# --- Logs Preparation ---
for log in ssh vmess vless trojan shadowsocks; do
    [ ! -f "/etc/log-create-$log.log" ] && echo "Log $log Account " > "/etc/log-create-$log.log"
done

# --- Summary ---
clear
ip_public=$(curl -s ipv4.icanhazip.com)
echo "============================================================" | tee -a log-install.txt
echo "   Installation Finished!" | tee -a log-install.txt
echo "   Domain     : $domain" | tee -a log-install.txt
echo "   Public IP  : $ip_public" | tee -a log-install.txt
echo "   SSL        : Installed via Certbot" | tee -a log-install.txt
echo "============================================================" | tee -a log-install.txt
echo "   OpenSSH      : 22/110" | tee -a log-install.txt
echo "   Websocket    : 80 / 443" | tee -a log-install.txt
echo "   Stunnel4     : 222, 777" | tee -a log-install.txt
echo "   Nginx        : 81" | tee -a log-install.txt
echo "   Vmess/Vless  : 80, 443, gRPC" | tee -a log-install.txt
echo "   Trojan       : 80, 443, gRPC" | tee -a log-install.txt
echo "   Shadowsocks  : 80, 443, gRPC" | tee -a log-install.txt
echo "============================================================" | tee -a log-install.txt
echo "Server will reboot in 10 seconds..."
sleep 10
reboot

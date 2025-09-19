#!/bin/bash
# Quick Setup | Script Setup Manager
# Edition : Stable Edition 1.0
# Author  : givps
# License : MIT
# (C) Copyright 2023
# =========================================

# non-interactive mode
export DEBIAN_FRONTEND=noninteractive

# ambil IP VPS
MYIP=$(wget -qO- ipv4.icanhazip.com)
MYIP2="s/xxxxxxxxx/$MYIP/g"
NET=$(ip -o -4 route show to default | awk '{print $5}')
source /etc/os-release
ver=$VERSION_ID

# warna (fix biar ga error)
green='\033[0;32m'
red='\033[0;31m'
yell='\033[0;33m'
NC='\033[0m'

# detail perusahaan
country=ID
state=Indonesia
locality=Jakarta
organization=none
organizationalunit=none
commonname=none
email=none

# update dan hapus firewall bawaan
apt update -y
apt dist-upgrade -y
apt-get remove --purge -y ufw firewalld exim4

# install paket dasar
apt install -y \
    screen curl jq bzip2 gzip vnstat coreutils rsyslog iftop zip unzip git \
    apt-transport-https build-essential figlet ruby python make cmake \
    net-tools nano sed gnupg gnupg1 bc dirmngr libxml-parser-perl neofetch \
    lsof libsqlite3-dev libz-dev gcc g++ libreadline-dev zlib1g-dev \
    libssl-dev libssl1.0-dev dos2unix fail2ban dropbear stunnel4 \
    wget curl shc

# password policy
curl -sS https://raw.githubusercontent.com/givps/givps-1.0/master/ssh/password \
  | openssl aes-256-cbc -d -a -pass pass:scvps07gg -pbkdf2 > /etc/pam.d/common-password
chmod +x /etc/pam.d/common-password

# timezone
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config

# rc.local service
cat > /etc/systemd/system/rc-local.service <<-EOF
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
EOF

cat > /etc/rc.local <<-EOF
#!/bin/sh -e
exit 0
EOF
chmod +x /etc/rc.local
systemctl enable rc-local
systemctl start rc-local.service

# disable ipv6 permanen
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
echo "echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6" >> /etc/rc.local

# nginx & web
apt install -y nginx
rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/givps/givps-1.0/master/ssh/nginx.conf"
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/givps/givps-1.0/master/ssh/vps.conf"
systemctl daemon-reload
systemctl restart nginx

mkdir -p /home/vps/public_html
wget -O /home/vps/public_html/index.html "https://raw.githubusercontent.com/givps/givps-1.0/master/ssh/index"
wget -O /home/vps/public_html/.htaccess "https://raw.githubusercontent.com/givps/givps-1.0/master/ssh/.htaccess"

# badvpn
wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/givps/givps-1.0/master/ssh/newudpgw"
chmod +x /usr/bin/badvpn-udpgw
for port in {7100..7900..100}; do
    screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:$port --max-clients 500
    echo "screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:$port --max-clients 500" >> /etc/rc.local
done

# ssh port tambahan
for port in 500 40000 81 51443 58080 666 200 22 2222 2269; do
    sed -i "/Port 22/a Port $port" /etc/ssh/sshd_config
done
systemctl restart ssh

# dropbear
sed -i 's/NO_START=1/NO_START=0/' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=143/' /etc/default/dropbear
sed -i 's@DROPBEAR_EXTRA_ARGS=@DROPBEAR_EXTRA_ARGS="-p 50000 -p 109 -p 110 -p 69"@' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
systemctl restart dropbear

# stunnel
cat > /etc/stunnel/stunnel.conf <<-EOF
cert = /etc/stunnel/stunnel.pem
client = no
[dropbear-ssh] 
accept = 222
connect = 127.0.0.1:22
[dropbear-alt]
accept = 777
connect = 127.0.0.1:109
[ws-stunnel]
accept = 2096
connect = 700
[openvpn]
accept = 442
connect = 127.0.0.1:1194
EOF

openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 1095 \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem
rm -f key.pem cert.pem
sed -i 's/ENABLED=0/ENABLED=1/' /etc/default/stunnel4
systemctl enable stunnel4
systemctl restart stunnel4

# banner
wget -O /etc/issue.net "https://raw.githubusercontent.com/givps/givps-1.0/master/banner/banner.conf"
echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config
sed -i 's@DROPBEAR_BANNER=""@DROPBEAR_BANNER="/etc/issue.net"@' /etc/default/dropbear

# ddos deflate
if [ ! -d "/usr/local/ddos" ]; then
    mkdir /usr/local/ddos
    wget -q -O /usr/local/ddos/ddos.sh http://www.inetbase.com/scripts/ddos/ddos.sh
    chmod 0755 /usr/local/ddos/ddos.sh
    ln -s /usr/local/ddos/ddos.sh /usr/local/sbin/ddos
    /usr/local/ddos/ddos.sh --cron >/dev/null 2>&1
fi

# blokir torrent
for key in "get_peers" "announce_peer" "find_node" "BitTorrent" \
"BitTorrent protocol" "peer_id=" ".torrent" "announce.php?passkey=" \
"torrent" "announce" "info_hash"; do
    iptables -A FORWARD -m string --algo bm --string "$key" -j DROP
done
netfilter-persistent save
netfilter-persistent reload

# download semua menu (link tetap)
cd /usr/bin
wget -q -O menu "https://raw.githubusercontent.com/givps/givps-1.0/master/menu/menu.sh"
wget -q -O m-vmess "https://raw.githubusercontent.com/givps/givps-1.0/master/menu/m-vmess.sh"
wget -q -O m-vless "https://raw.githubusercontent.com/givps/givps-1.0/master/menu/m-vless.sh"
wget -q -O running "https://raw.githubusercontent.com/givps/givps-1.0/master/menu/running.sh"
wget -q -O clearcache "https://raw.githubusercontent.com/givps/givps-1.0/master/menu/clearcache.sh"
wget -q -O m-ssws "https://raw.githubusercontent.com/givps/givps-1.0/master/menu/m-ssws.sh"
wget -q -O m-trojan "https://raw.githubusercontent.com/givps/givps-1.0/master/menu/m-trojan.sh"
wget -q -O m-sshovpn "https://raw.githubusercontent.com/givps/givps-1.0/master/menu/m-sshovpn.sh"
wget -q -O usernew "https://raw.githubusercontent.com/givps/givps-1.0/master/ssh/usernew.sh"
wget -q -O trial "https://raw.githubusercontent.com/givps/givps-1.0/master/ssh/trial.sh"
wget -q -O renew "https://raw.githubusercontent.com/givps/givps-1.0/master/ssh/renew.sh"
wget -q -O hapus "https://raw.githubusercontent.com/givps/givps-1.0/master/ssh/hapus.sh"
wget -q -O cek "https://raw.githubusercontent.com/givps/givps-1.0/master/ssh/cek.sh"
wget -q -O member "https://raw.githubusercontent.com/givps/givps-1.0/master/ssh/member.sh"
wget -q -O delete "https://raw.githubusercontent.com/givps/givps-1.0/master/ssh/delete.sh"
wget -q -O autokill "https://raw.githubusercontent.com/givps/givps-1.0/master/ssh/autokill.sh"
wget -q -O ceklim "https://raw.githubusercontent.com/givps/givps-1.0/master/ssh/ceklim.sh"
wget -q -O autokick "https://raw.githubusercontent.com/givps/givps-1.0/master/ssh/autokick.sh"
wget -q -O sshws "https://raw.githubusercontent.com/givps/givps-1.0/master/ssh/sshws.sh"
wget -q -O user-lockunlock "https://raw.githubusercontent.com/givps/givps-1.0/master/ssh/user-lockunlock.sh"
wget -q -O m-system "https://raw.githubusercontent.com/givps/givps-1.0/master/menu/m-system.sh"
wget -q -O m-domain "https://raw.githubusercontent.com/givps/givps-1.0/master/menu/m-domain.sh"
wget -q -O add-host "https://raw.githubusercontent.com/givps/givps-1.0/master/ssh/add-host.sh"
wget -q -O certv2ray "https://raw.githubusercontent.com/givps/givps-1.0/master/xray/certv2ray.sh"
wget -q -O speedtest "https://raw.githubusercontent.com/givps/givps-1.0/master/ssh/speedtest_cli.py"
wget -q -O auto-reboot "https://raw.githubusercontent.com/givps/givps-1.0/master/menu/auto-reboot.sh"
wget -q -O restart "https://raw.githubusercontent.com/givps/givps-1.0/master/menu/restart.sh"
wget -q -O bw "https://raw.githubusercontent.com/givps/givps-1.0/master/menu/bw.sh"
wget -q -O m-tcp "https://raw.githubusercontent.com/givps/givps-1.0/master/menu/tcp.sh"
wget -q -O xp "https://raw.githubusercontent.com/givps/givps-1.0/master/ssh/xp.sh"
wget -q -O m-dns "https://raw.githubusercontent.com/givps/givps-1.0/master/menu/m-dns.sh"

chmod +x /usr/bin/*

# cron jobs
cat > /etc/cron.d/re_otm <<-EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 2 * * * root /sbin/reboot
EOF

cat > /etc/cron.d/xp_otm <<-EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 0 * * * root /usr/bin/xp
EOF

# bersihkan sampah
apt autoremove -y
apt autoclean -y
history -c
echo "unset HISTFILE" >> /etc/profile

# finishing
systemctl restart nginx openvpn cron ssh dropbear fail2ban stunnel4 vnstat squid
chown -R www-data:www-data /home/vps/public_html
clear
echo -e "${green}[INFO] Setup selesai.${NC}"

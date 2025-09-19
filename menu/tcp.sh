#!/usr/bin/env bash
#
# Unified Accelerator & System Manager
# Cleaned, consolidated script for:
#  - Kernel installers (BBR, BBRplus, LotServer, BBR-mod)
#  - Enable/disable congestion controls
#  - System optimization (sysctl & limits)
#  - Basic utilities + self-update
#  - Menu-driven interface
#
# NOTES:
#  - Run as root.
#  - Review placeholders and comments before running.
#  - This script *may* change boot kernel and require a reboot.
#
# Author: adapted/cleaned by givps (from multiple fragments)
# License: MIT
# Version: 1.0.0 (clean)
set -euo pipefail
IFS=$'\n\t'

### -------- Configuration/Constants --------
SCRIPT_VER="1.0.0"
GITHUB_RAW_BASE="https://raw.githubusercontent.com/chiakge/Linux-NetSpeed/master"  # used by some kernel helpers
LOGFILE="/var/log/accel-manager.log"
# Placeholders for values that must be changed responsibly:
CLOUDFLARE_ZONE_ID=""   # if you intend to use Cloudflare DNS automation
CLOUDFLARE_API_TOKEN="" # set an API token if using DNS creation

### -------- Colors & helpers --------
_GREEN="\033[0;32m"; _RED="\033[0;31m"; _YEL="\033[0;33m"; _NC="\033[0m"
info()  { echo -e "${_GREEN}[INFO]${_NC} $*"; }
warn()  { echo -e "${_YEL}[WARN]${_NC} $*"; }
error() { echo -e "${_RED}[ERROR]${_NC} $*" >&2; }

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >>"${LOGFILE}"
}

require_root() {
  if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root."
    exit 1
  fi
}

safe_cmd() {
  # run a command and log output to logfile. Accepts command as argument string.
  # Usage: safe_cmd "apt-get update -y"
  local cmd="$*"
  log "CMD: $cmd"
  bash -c "$cmd" >>"${LOGFILE}" 2>&1 || {
    error "Command failed: $cmd"
    return 1
  }
  return 0
}

### -------- Environment & detection --------
export DEBIAN_FRONTEND=noninteractive

detect_os() {
  # sets global variables: release, version, bit
  release=""
  version=""
  bit="$(uname -m)"
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    case "${ID,,}" in
      ubuntu) release="ubuntu" ;;
      debian) release="debian" ;;
      centos) release="centos" ;;
      rhel) release="centos" ;;
      *) release="${ID,,}" ;;
    esac
    # numeric version
    version="${VERSION_ID%%.*}"
  else
    if [[ -f /etc/redhat-release ]]; then
      release="centos"
      version="$(cut -d' ' -f3 /etc/redhat-release | cut -d'.' -f1)"
    fi
  fi
  if [[ "${bit}" == "x86_64" ]]; then bit="x64"; else bit="x32"; fi
}

### -------- Package helpers --------
install_prereqs() {
  info "Installing prerequisite packages..."
  if command -v apt-get >/dev/null 2>&1; then
    safe_cmd "apt-get update -y"
    safe_cmd "apt-get install -y wget curl jq build-essential ca-certificates gnupg dirmngr lsb-release unzip"
  elif command -v yum >/dev/null 2>&1; then
    safe_cmd "yum install -y epel-release wget curl jq gcc make ca-certificates"
  else
    warn "Unknown package manager. Please install required packages manually."
  fi
}

### -------- Kernel helpers (high level) --------
# These are wrapper functions. For production use, review each function and
# verify remote URLs or replace with local packages.
install_bbr_kernel() {
  # Install a modern mainline kernel that supports BBR. This is a simplified wrapper.
  info "Installing BBR-compatible kernel (mainline)..."
  detect_os
  if [[ "${release}" == "ubuntu" || "${release}" == "debian" ]]; then
    info "Using Debian/Ubuntu workflow to install mainline kernel (via apt)."
    # Using canonical mainline packages may not be feasible on all systems.
    # For safety, propose using the distro's backport kernel or instruct the user.
    echo "Please install a kernel >= 4.9 (or 5.x) appropriate for your distro."
    echo "Example (Ubuntu): sudo apt install linux-image-generic -y"
    return 0
  elif [[ "${release}" == "centos" ]]; then
    info "CentOS: please install ELRepo kernel-ml or a supported kernel manually."
    echo "Example: yum --enablerepo=elrepo-kernel install kernel-ml -y"
    return 0
  else
    warn "Unsupported release: ${release}. Please install kernel manually."
    return 1
  fi
}

install_bbrplus_kernel() {
  info "Installing BBRplus kernel (wrapper)."
  warn "BBRplus kernel is a 3rd-party kernel. Install with caution. This wrapper only gives instructions."
  echo "For Debian/Ubuntu: download and install linux-image-* bbrplus packages if available."
}

install_lotserver_kernel() {
  info "Installing LotServer kernel (wrapper)."
  warn "LotServer (锐速) is proprietary and installation mechanisms differ by distro. This wrapper only gives instructions."
  echo "Refer to official LotServer repository for installation commands."
}

install_bbrmod_from_source() {
  info "Compiling BBR magic module (tcp_tsunami) from source."
  detect_os
  if [[ "${release}" == "centos" ]]; then
    safe_cmd "yum install -y make gcc"
  else
    safe_cmd "apt-get install -y make gcc"
  fi
  tmpd="$(mktemp -d)"
  pushd "${tmpd}" >/dev/null
  safe_cmd "wget -q -O tcp_tsunami.c ${GITHUB_RAW_BASE}/bbr/tcp_tsunami.c"
  cat >Makefile <<'EOF'
obj-m:=tcp_tsunami.o
EOF
  safe_cmd "make -C /lib/modules/$(uname -r)/build M=$(pwd) modules || true"
  if [[ -f tcp_tsunami.ko ]]; then
    safe_cmd "cp -f tcp_tsunami.ko /lib/modules/$(uname -r)/kernel/net/ipv4/"
    safe_cmd "depmod -a"
    info "Module compiled and installed. To enable it, load it (insmod) and set sysctl."
  else
    error "Build failed. Check kernel headers and build environment."
  fi
  popd >/dev/null
  rm -rf "${tmpd}"
}

### -------- Enable/Disable algorithms --------
enable_bbr() {
  info "Enabling BBR (net.ipv4.tcp_congestion_control=bbr)"
  # set fq for recent kernels
  if [[ $(uname -r | cut -d. -f1) -ge 5 ]]; then
    sysctl -w net.core.default_qdisc=cake >/dev/null 2>&1 || true
  else
    sysctl -w net.core.default_qdisc=fq >/dev/null 2>&1 || true
  fi
  sysctl -w net.ipv4.tcp_congestion_control=bbr
  # persist
  if ! grep -q "net.ipv4.tcp_congestion_control" /etc/sysctl.conf 2>/dev/null; then
    cat >> /etc/sysctl.conf <<'EOF'
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF
  else
    sed -i 's/^net.ipv4.tcp_congestion_control.*/net.ipv4.tcp_congestion_control=bbr/' /etc/sysctl.conf || true
    sed -i 's/^net.core.default_qdisc.*/net.core.default_qdisc=fq/' /etc/sysctl.conf || true
  fi
  sysctl -p >/dev/null 2>&1 || true
  info "BBR enabled. Check with: lsmod | grep bbr  and sysctl net.ipv4.tcp_congestion_control"
}

enable_bbrplus() {
  info "Enable BBRplus (if kernel supports it)."
  sysctl -w net.core.default_qdisc=fq
  sysctl -w net.ipv4.tcp_congestion_control=bbrplus || warn "bbrplus not available on this kernel."
  # persist
  if ! grep -q "bbrplus" /etc/sysctl.conf 2>/dev/null; then
    cat >> /etc/sysctl.conf <<'EOF'
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbrplus
EOF
  fi
  sysctl -p >/dev/null 2>&1 || true
}

enable_bbrmod_tsunami() {
  info "Enable BBR magic (tsunami). Attempting to load module if present."
  if ! lsmod | grep -q tcp_tsunami; then
    if [[ -f /lib/modules/$(uname -r)/kernel/net/ipv4/tcp_tsunami.ko ]]; then
      modprobe tcp_tsunami || insmod /lib/modules/$(uname -r)/kernel/net/ipv4/tcp_tsunami.ko || true
    else
      warn "tcp_tsunami module not found. Compile it using the compile helper."
      return 1
    fi
  fi
  sysctl -w net.core.default_qdisc=fq
  sysctl -w net.ipv4.tcp_congestion_control=tsunami
  if ! grep -q "tcp_congestion_control=tsunami" /etc/sysctl.conf 2>/dev/null; then
    cat >>/etc/sysctl.conf <<'EOF'
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=tsunami
EOF
  fi
  sysctl -p >/dev/null 2>&1 || true
  info "BBR-magic (tsunami) enabled."
}

disable_acceleration() {
  info "Removing acceleration entries from sysctl.conf"
  sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf || true
  sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf || true
  sysctl -p >/dev/null 2>&1 || true
  info "Acceleration disabled (system defaults restored)."
}

### -------- System optimization --------
apply_sys_optimizations() {
  info "Applying system optimizations (sysctl + ulimit)."
  # backup
  cp -f /etc/sysctl.conf /etc/sysctl.conf.bak.$$ || true
  cat >>/etc/sysctl.conf <<'EOF'

# Custom tuning added by accel-manager
fs.file-max = 1000000
fs.inotify.max_user_instances = 8192
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_rmem = 16384 262144 8388608
net.ipv4.tcp_wmem = 32768 524288 16777216
net.core.somaxconn = 8192
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 10240
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_max_syn_backlog = 10240
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.ip_forward = 1
EOF
  sysctl -p >/dev/null 2>&1 || true
  # limits
  cat >/etc/security/limits.conf <<'EOF'
# Limits set by accel-manager
*               soft    nofile           1000000
*               hard    nofile          1000000
EOF
  if ! grep -q "ulimit -SHn 1000000" /etc/profile 2>/dev/null; then
    echo "ulimit -SHn 1000000" >>/etc/profile
  fi
  info "System optimizations applied. A reboot is recommended for some kernel changes."
}

### -------- Utility operations --------
self_update() {
  info "Self-update: retrieving latest version from repo..."
  local remote_url="${GITHUB_RAW_BASE}/tcp.sh"
  if curl -fsSL "${remote_url}" -o /tmp/tcp.sh.new; then
    chmod +x /tmp/tcp.sh.new
    mv -f /tmp/tcp.sh.new "${BASH_SOURCE[0]}"
    info "Script updated in place. New version will be used next run."
  else
    error "Failed to fetch remote script."
  fi
}

show_status() {
  echo "===== Acceleration Status ====="
  uname -r
  sysctl net.ipv4.tcp_congestion_control || true
  sysctl net.core.default_qdisc || true
  echo "Loaded modules:"
  lsmod | egrep 'bbr|tsunami|nanqinlang|bbrplus' || true
  echo "================================"
}

### -------- Menu & UI --------
main_menu() {
  while true; do
    clear
    detect_os
    echo "==========================================="
    echo " Accelerator & System Manager - v${SCRIPT_VER}"
    echo " Detected OS: ${release:-unknown} ${version:-n/a} (${bit})"
    echo " Log: ${LOGFILE}"
    echo "==========================================="
    echo " 1) Install prerequisites"
    echo " 2) Install BBR kernel (instruction)"
    echo " 3) Install BBRplus kernel (instruction)"
    echo " 4) Install LotServer (instruction)"
    echo " 5) Compile BBR-mod (tcp_tsunami) from source"
    echo " 6) Enable BBR"
    echo " 7) Enable BBRplus"
    echo " 8) Enable BBR-mod (tsunami)"
    echo " 9) Disable acceleration (restore defaults)"
    echo "10) Apply system optimizations (sysctl & limits)"
    echo "11) Self-update script"
    echo "12) Show acceleration status"
    echo "0) Exit"
    echo "-------------------------------------------"
    read -rp "Choose an option [0-12]: " choice
    case "${choice}" in
      1) install_prereqs; read -rp "Done. Press enter to continue... " _ ;;
      2) install_bbr_kernel; read -rp "Done. Press enter to continue... " _ ;;
      3) install_bbrplus_kernel; read -rp "Done. Press enter to continue... " _ ;;
      4) install_lotserver_kernel; read -rp "Done. Press enter to continue... " _ ;;
      5) install_bbrmod_from_source; read -rp "Done. Press enter to continue... " _ ;;
      6) enable_bbr; read -rp "Done. Press enter to continue... " _ ;;
      7) enable_bbrplus; read -rp "Done. Press enter to continue... " _ ;;
      8) enable_bbrmod_tsunami; read -rp "Done. Press enter to continue... " _ ;;
      9) disable_acceleration; read -rp "Done. Press enter to continue... " _ ;;
      10) apply_sys_optimizations; read -rp "Done. Press enter to continue... " _ ;;
      11) self_update; read -rp "Updated. Press enter to continue... " _ ;;
      12) show_status; read -rp "Press enter to continue... " _ ;;
      0) info "Exiting."; exit 0 ;;
      *) warn "Invalid option"; sleep 1 ;;
    esac
  done
}

### -------- Entrypoint --------
require_root
mkdir -p "$(dirname "${LOGFILE}")"
touch "${LOGFILE}" 2>/dev/null || true
log "Script started (version ${SCRIPT_VER}) by $(whoami) on $(hostname)"

main_menu

#!/bin/bash
# m-trojan-view - show active Trojan user logins + access count + last seen
# Author : givps
# Edition: Stable Edition 1.2

set -u

# Colors
BLUE='\033[0;34m'; NC='\033[0m'; RED='\033[0;31m'

CONFIG="/etc/xray/config.json"
ACCESS_LOG="/var/log/xray/access.log"

# temp files
TMP_CONNECTED=$(mktemp) || exit 1
TMP_MATCHED=$(mktemp) || exit 1

cleanup() {
  rm -f "$TMP_CONNECTED" "$TMP_MATCHED"
}
trap cleanup EXIT

echo "Checking VPS and xray files..."
if [[ ! -f "$CONFIG" ]]; then
  echo -e "${RED}Error:${NC} $CONFIG not found."
  exit 1
fi

# 1) collect users from config markers like: ### username 2025-09-19
mapfile -t USERS < <(grep -E '^### ' "$CONFIG" 2>/dev/null | awk '{print $2}' | sort -u)

# 2) connected remote IPs observed from ss (established with process name xray)
ss -tnp state established 2>/dev/null \
  | awk '/ESTAB/ && /xray/ {print $5}' \
  | sed -E 's/^\[//; s/\]$//' \
  | sed -E 's/:[0-9]+$//' \
  | sort -u > "$TMP_CONNECTED"

echo -e "${BLUE}-----------------------------------------${NC}"
echo -e "${BLUE}---------=[ Trojan User Login ]=---------${NC}"
echo -e "${BLUE}-----------------------------------------${NC}"

> "$TMP_MATCHED"

# 3) loop users
for u in "${USERS[@]}"; do
  [[ -z "$u" ]] && continue

  declare -A IP_COUNT=()
  declare -A IP_LASTSEEN=()

  # ambil log user -> IP + hitung + last seen
  if [[ -f "$ACCESS_LOG" ]]; then
    while read -r line; do
      ip=$(echo "$line" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}')
      [[ -z "$ip" ]] && continue
      ts=$(echo "$line" | awk '{print $1" "$2" "$3}')
      IP_COUNT["$ip"]=$(( ${IP_COUNT["$ip"]:-0} + 1 ))
      IP_LASTSEEN["$ip"]="$ts"
    done < <(grep -F -- "$u" "$ACCESS_LOG" 2>/dev/null)
  fi

  # tampilkan hanya IP yang juga sedang terkoneksi
  mapfile -t ACTIVE_IPS < <(comm -12 <(printf "%s\n" "${!IP_COUNT[@]}" | sort) "$TMP_CONNECTED")

  if [[ ${#ACTIVE_IPS[@]} -gt 0 ]]; then
    echo -e "${BLUE}user :${NC} $u"
    i=1
    for ip in "${ACTIVE_IPS[@]}"; do
      echo "  $i. $ip  (hits: ${IP_COUNT[$ip]}, last seen: ${IP_LASTSEEN[$ip]})"
      echo "$ip" >> "$TMP_MATCHED"
      ((i++))
    done
    echo -e "${BLUE}-----------------------------------------${NC}"
  fi
done

# 4) tampilkan "other"
if [[ -s "$TMP_CONNECTED" ]]; then
  echo -e "${BLUE}Other connected IPs:${NC}"
  comm -23 "$TMP_CONNECTED" <(sort -u "$TMP_MATCHED") | nl -ba -w2 -s'. '
else
  echo "No current established xray connections found."
fi

echo -e "${BLUE}-----------------------------------------${NC}"
read -n 1 -s -r -p "Press any key to return to menu..."
if command -v m-trojan >/dev/null 2>&1; then
  m-trojan
fi

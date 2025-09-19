#!/bin/bash
# m-vless-view - show active VLESS user logins with hits + last seen (improved)
# Place: /usr/local/bin/m-vless-view
# Usage: run as root (reads /etc/xray/config.json and /var/log/xray/access.log)

set -u

# Colors
BLUE='\033[0;34m'; NC='\033[0m'; RED='\033[0;31m'; YELL='\033[0;33m'

CONFIG="/etc/xray/config.json"
ACCESS_LOG="/var/log/xray/access.log"

# temp files (will be removed on exit)
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

# 1) collect users from config markers like: ### username 2025-09-19 or #### username ...
mapfile -t USERS < <(grep -E '^#{3,4} ' "$CONFIG" 2>/dev/null | awk '{print $2}' | sort -u)

# 2) collect current connected remote IPs from ss (established connections belonging to process xray)
# output format of ss $5 may contain [::ffff:1.2.3.4]:port or 1.2.3.4:port
ss -tnp state established 2>/dev/null \
  | awk '/ESTAB/ && /xray/ {print $5}' \
  | sed -E 's/^\[//; s/\]$//' \
  | sed -E 's/:[0-9]+$//' \
  | sed -E 's/^::ffff://' \
  | sort -u > "$TMP_CONNECTED"

echo -e "${BLUE}----------------------------------------${NC}"
echo -e "${BLUE}---------=[ VLESS User Login ]=---------${NC}"
echo -e "${BLUE}----------------------------------------${NC}"

> "$TMP_MATCHED"

if [[ ${#USERS[@]} -eq 0 ]]; then
  echo -e "${YELL}No VLESS users found in config markers (### or ####).${NC}"
fi

# 3) Loop users: compute hits and last seen per IP, show only active (connected) IPs
for u in "${USERS[@]}"; do
  [[ -z "$u" ]] && continue

  declare -A IP_COUNT=()
  declare -A IP_LASTSEEN=()

  # read user's log lines, extract IPv4 addresses and timestamps
  if [[ -f "$ACCESS_LOG" ]]; then
    # grep lines containing the username (safer with fixed string)
    while IFS= read -r line; do
      # extract first IPv4 in the line (if any)
      ip=$(echo "$line" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n1)
      [[ -z "$ip" ]] && continue
      # attempt to extract timestamp from start of the log line (adjust if your log format differs)
      # this assumes timestamp is in the first 2-3 fields like: "2025-09-19 10:32:14 ..." or similar
      ts=$(echo "$line" | awk '{if (NF>=3) {print $1" "$2" "$3} else {print $1}}')
      IP_COUNT["$ip"]=$(( ${IP_COUNT["$ip"]:-0} + 1 ))
      # keep latest timestamp (overwrite so the last occurrence remains)
      IP_LASTSEEN["$ip"]="$ts"
    done < <(grep -F -- "$u" "$ACCESS_LOG" 2>/dev/null || true)
  fi

  # get intersection with currently connected IPs
  # prepare sorted list of IPs for comm
  if [[ ${#IP_COUNT[@]} -gt 0 ]]; then
    mapfile -t USER_IPS <<< "$(printf "%s\n" "${!IP_COUNT[@]}" | sort)"
    mapfile -t ACTIVE_IPS <<< "$(comm -12 <(printf "%s\n" "${USER_IPS[@]}" | sort) "$TMP_CONNECTED")"
  else
    ACTIVE_IPS=()
  fi

  if [[ ${#ACTIVE_IPS[@]} -gt 0 ]]; then
    echo -e "${BLUE}user :${NC} $u"
    i=1
    for ip in "${ACTIVE_IPS[@]}"; do
      hits=${IP_COUNT[$ip]:-0}
      last=${IP_LASTSEEN[$ip]:-"N/A"}
      printf "  %d. %s  (hits: %s, last seen: %s)\n" "$i" "$ip" "$hits" "$last"
      echo "$ip" >> "$TMP_MATCHED"
      ((i++))
    done
    echo -e "${BLUE}----------------------------------------${NC}"
  fi
done

# 4) show "other" connected IPs that didn't match any user
sort -u "$TMP_MATCHED" -o "$TMP_MATCHED"
if [[ -s "$TMP_CONNECTED" ]]; then
  echo -e "${BLUE}Other connected IPs:${NC}"
  comm -23 "$TMP_CONNECTED" "$TMP_MATCHED" | nl -ba -w2 -s'. '
else
  echo "No current established xray connections found."
fi

echo -e "${BLUE}----------------------------------------${NC}"
read -n 1 -s -r -p "Press any key to return to menu..."

# return to menu if exists
if command -v m-vless >/dev/null 2>&1; then
  m-vless
fi

exit 0

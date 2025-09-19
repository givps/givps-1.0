#!/bin/bash
# =========================================
# Xray Universal Auto-Cleaner Installer
# Author  : givps
# =========================================

CLEANER_PATH="/usr/local/bin/xray-cleaner"

# Buat script cleaner
cat > $CLEANER_PATH <<'EOF'
#!/bin/bash
# =========================================
# Xray Universal Auto-Cleaner
# Author  : givps
# =========================================

CONFIG="/etc/xray/config.json"
TODAY=$(date +%s)

# scan marker ### username exp
grep -E "^### " $CONFIG | while read -r marker; do
    USER=$(echo $marker | awk '{print $2}')
    EXP=$(echo $marker | awk '{print $3}')
    EXP_TS=$(date -d "$EXP" +%s)

    if [[ $EXP_TS -le $TODAY ]]; then
        # hapus semua block user expired
        sed -i "/^### $USER $EXP/,/^},{/d" $CONFIG
        echo "Expired user removed: $USER ($EXP)"
    fi
done

systemctl restart xray >/dev/null 2>&1
EOF

# Set permission
chmod +x $CLEANER_PATH

# Pasang cron job
CRON_FILE="/etc/cron.d/xray-cleaner"
cat > $CRON_FILE <<EOF
*/30 * * * * root $CLEANER_PATH >/dev/null 2>&1
EOF

echo "✅ Xray Universal Auto-Cleaner terpasang!"
echo "➡ Script : $CLEANER_PATH"
echo "➡ Cron   : $CRON_FILE (jalan tiap 30 menit)"
sleep 5
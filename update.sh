#!/bin/bash
  cd /root/BotZiVPN
    timedatectl set-timezone Asia/Jakarta || echo -e "${red}Failed to set timezone to Jakarta${neutral}"
sudo apt remove nodejs -y
sudo apt purge nodejs -y
sudo apt autoremove -y
    if ! dpkg -s nodejs >/dev/null 2>&1; then
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - || echo -e "${red}Failed to download Node.js setup${neutral}"
        apt-get install -y nodejs || echo -e "${red}Failed to install Node.js${neutral}"
    else
        echo -e "${green}Node.js is already installed, skipping...${neutral}"
    fi

    if [ ! -f /root/BotZiVPN/app.js ]; then
        git clone https://github.com/arivpnstores/BotZiVPN.git /root/BotZiVPN
    fi
apt install jq -y
apt install npm pm2 -y
npm install -g npm@latest
npm install -g pm2

    if ! npm list --prefix /root/BotZiVPN express telegraf axios moment sqlite3 >/dev/null 2>&1; then
        npm install --prefix /root/BotZiVPN sqlite3 express crypto telegraf axios dotenv
    fi

    if [ -n "$(ls -A /root/BotZiVPN)" ]; then
        chmod +x /root/BotZiVPN/*
    fi
 wget --connect-timeout=1 --timeout=30 -O .gitattributes "https://raw.githubusercontent.com/arivpnstores/BotZiVPN/main/.gitattributes"
 wget --connect-timeout=1 --timeout=30 -O README.md "https://raw.githubusercontent.com/arivpnstores/BotZiVPN/main/README.md"
 wget --connect-timeout=1 --timeout=30 -O app.js "https://raw.githubusercontent.com/arivpnstores/BotZiVPN/main/app.js"
 wget --connect-timeout=1 --timeout=30 -O wd.py "https://raw.githubusercontent.com/arivpnstores/BotZiVPN/main/wd.py"
 wget --connect-timeout=1 --timeout=30 -O cek-port.sh "https://raw.githubusercontent.com/arivpnstores/BotZiVPN/main/cek-port.sh"
 wget --connect-timeout=1 --timeout=30 -O ecosystem.config.js "https://raw.githubusercontent.com/arivpnstores/BotZiVPN/main/ecosystem.config.js"
 wget --connect-timeout=1 --timeout=30 -O package.json "https://raw.githubusercontent.com/arivpnstores/BotZiVPN/main/package.json"
 wget --connect-timeout=1 --timeout=30 -O ss.png "https://raw.githubusercontent.com/arivpnstores/BotZiVPN/main/ss.png"
 wget --connect-timeout=1 --timeout=30 -O ss2.png "https://raw.githubusercontent.com/arivpnstores/BotZiVPN/main/ss2.png"
 wget --connect-timeout=1 --timeout=30 -O start "https://raw.githubusercontent.com/arivpnstores/BotZiVPN/main/start"
 wget --connect-timeout=1 --timeout=30 -O update.sh "https://raw.githubusercontent.com/arivpnstores/BotZiVPN/main/update.sh"
 wget --connect-timeout=1 --timeout=30 -O /root/BotZiVPN/modules/reseller.js "https://raw.githubusercontent.com/arivpnstores/BotZiVPN/main/modules/reseller.js"
 wget --connect-timeout=1 --timeout=30 -O /root/BotZiVPN/modules/create.js "https://raw.githubusercontent.com/arivpnstores/BotZiVPN/main/modules/create.js"
 wget --connect-timeout=1 --timeout=30 -O /root/BotZiVPN/modules/del.js "https://raw.githubusercontent.com/arivpnstores/BotZiVPN/main/modules/del.js"
 wget --connect-timeout=1 --timeout=30 -O /root/BotZiVPN/modules/renew.js "https://raw.githubusercontent.com/arivpnstores/BotZiVPN/main/modules/renew.js"
 wget --connect-timeout=1 --timeout=30 -O /root/BotZiVPN/modules/trial.js "https://raw.githubusercontent.com/arivpnstores/BotZiVPN/main/modules/trial.js"

# stop dulu servicenya
systemctl stop sellzivpn.service

# nonaktifkan supaya tidak jalan saat boot
systemctl disable sellzivpn.service

# hapus file service dari systemd
rm -f /etc/systemd/system/sellzivpn.service

# reload systemd biar bersih
systemctl daemon-reload
systemctl reset-failed


pm2 start ecosystem.config.js
pm2 save

cat >/usr/bin/backup_sellzivpn <<'EOF'
#!/bin/bash
# File: /usr/bin/backup_sellzivpn
# Pastikan chmod +x /usr/bin/backup_sellzivpn

VARS_FILE="/root/BotZiVPN/.vars.json"
DB_FOLDER="/root/BotZiVPN"

# Cek file .vars.json
if [ ! -f "$VARS_FILE" ]; then
    echo "❌ File $VARS_FILE tidak ditemukan"
    exit 1
fi

# Ambil nilai dari .vars.json
BOT_TOKEN=$(jq -r '.BOT_TOKEN' "$VARS_FILE")
USER_ID=$(jq -r '.USER_ID' "$VARS_FILE")

if [ -z "$BOT_TOKEN" ] || [ -z "$USER_ID" ]; then
    echo "❌ BOT_TOKEN atau USER_ID kosong di $VARS_FILE"
    exit 1
fi

# Daftar file database
DB_FILES=("sellzivpn.db" "trial.db" "ressel.db")

for DB_FILE in "${DB_FILES[@]}"; do
    FILE_PATH="$DB_FOLDER/$DB_FILE"
    if [ -f "$FILE_PATH" ]; then
        curl -s --connect-timeout 1 --max-time 3 -F chat_id="$USER_ID" \
             -F document=@"$FILE_PATH" \
             "https://api.telegram.org/bot$BOT_TOKEN/sendDocument" >/dev/null 2>&1
        echo "✅ $DB_FILE terkirim ke Telegram"
    else
        echo "❌ File $DB_FILE tidak ditemukan"
    fi
done

echo "✅ Semua backup selesai."
EOF

# bikin cron job tiap 1 jam
cat >/etc/cron.d/backup_sellzivpn <<'EOF'
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 0 * * * root /usr/bin/backup_sellzivpn
EOF

chmod +x /usr/bin/backup_sellzivpn
service cron restart

    echo -e "${orange}─────────────────────────────────────────${neutral}"
    echo -e "   ${green}.:::. BOT TELEGRAM UPDATE .:::.   ${neutral}"
    echo -e "${orange}─────────────────────────────────────────${neutral}"
    read -p "Masukkan token bot: " token
    while [ -z "$token" ]; do
        read -p "Masukkan token bot: " token
        if [ -z "$token" ]; then
            echo -e "${red}Token bot tidak boleh kosong. Silakan coba lagi.${neutral}"
        fi
    done
    while [ -z "$adminid" ]; do
        read -p "Masukkan admin ID: " adminid
        if [ -z "$adminid" ]; then
            echo -e "${red}Admin ID tidak boleh kosong. Silakan coba lagi.${neutral}"
        fi
    done
    while [ -z "$namastore" ]; do
        read -p "Masukkan nama store: " namastore
        if [ -z "$namastore" ]; then
            echo -e "${red}Nama store tidak boleh kosong. Silakan coba lagi.${neutral}"
        fi
    done
    while [ -z "$dataqris" ]; do
        read -p "Masukkan DATA QRIS: " dataqris
        if [ -z "$dataqris" ]; then
            echo -e "${red}DATA QRIS tidak boleh kosong. Silakan coba lagi.${neutral}"
        fi
    done
    while [ -z "$MERCHANT_ID" ]; do
        read -p "Masukkan MERCHANT_ID : " MERCHANT_ID
        if [ -z "$MERCHANT_ID" ]; then
            echo -e "${red}MERCHANT_ID tidak boleh kosong. Silakan coba lagi.${neutral}"
        fi
    done
    while [ -z "$GOPAY_KEY" ]; do
        read -p "Masukkan GOPAY_KEY : " GOPAY_KEY
        if [ -z "$GOPAY_KEY" ]; then
            echo -e "${red}GOPAY_KEY tidak boleh kosong. Silakan coba lagi.${neutral}"
        fi
    done
    while [ -z "$AUTH_PAYMET_GETWAY" ]; do
        read -p "Masukkan AUTH_PAYMET_GETWAY : " AUTH_PAYMET_GETWAY
        if [ -z "$AUTH_PAYMET_GETWAY" ]; then
            echo -e "${red}AUTH_PAYMET_GETWAY tidak boleh kosong. Silakan coba lagi.${neutral}"
        fi
    done
    while [ -z "$web_mutasi" ]; do
        read -p "Masukkan web_mutasi : " web_mutasi
        if [ -z "$web_mutasi" ]; then
            echo -e "${red}web_mutasi tidak boleh kosong. Silakan coba lagi.${neutral}"
        fi
    done
    while [ -z "$groupid" ]; do
        read -p "Masukkan ID GROUP NOTIF : " groupid
        if [ -z "$groupid" ]; then
            echo -e "${red}DATA QRIS tidak boleh kosong. Silakan coba lagi.${neutral}"
        fi
    done
    rm -f /root/BotZiVPN/.vars.json
    echo "{
  \"BOT_TOKEN\": \"$token\",
  \"USER_ID\": \"$adminid\",
  \"NAMA_STORE\": \"$namastore\",
  \"GROUP_ID\": \"$groupid\",
  \"PORT\": \"6969\",
  \"DATA_QRIS\": \"$dataqris\",
  \"MERCHANT_ID\": \"$MERCHANT_ID\",
  \"GOPAY_KEY\": \"$GOPAY_KEY\",
  \"AUTH_PAYMET_GETWAY\": \"$AUTH_PAYMET_GETWAY\",
  \"web_mutasi\": \"$web_mutasi\"
}" >/root/BotZiVPN/.vars.json


cd 
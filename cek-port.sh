#!/bin/bash

# Daftar server (ubah sesuai kebutuhan)
servers=(
  "biznet.rajaserverpremium.web.id"
  "biznet2.rajaserverpremium.web.id"
  "biznet3.rajaserverpremium.web.id"
  "biznet4.rajaserverpremium.web.id"
  "biznet5.rajaserverpremium.web.id"
  "ikd.rajaserverpremium.web.id"
)

# Daftar port + label
declare -A ports
ports=(
  [22]="VPS LOGIN"
)

# Warna
green="\e[32m"
red="\e[31m"
nc="\e[0m"

echo "🔍 Cek status server"
echo "-------------------------------------------"

# Loop setiap server
for server in "${servers[@]}"; do
  echo -e "\n🌐 Server: $server"

  # Jika nama server mengandung "udp-" hanya cek port 22
  if [[ "$server" == *"udp-"* ]]; then
    port=22
    timeout 2 bash -c "</dev/tcp/$server/$port" &>/dev/null
    if [[ $? -eq 0 ]]; then
      echo -e "  Port $port (${ports[$port]}): ${green}OPEN${nc}"
    else
      echo -e "  Port $port (${ports[$port]}): ${red}CLOSED${nc}"
    fi
  else
    # Cek semua port untuk server SSL
    for port in "${!ports[@]}"; do
      timeout 2 bash -c "</dev/tcp/$server/$port" &>/dev/null
      if [[ $? -eq 0 ]]; then
        echo -e "  Port $port (${ports[$port]}): ${green}OPEN${nc}"
      else
        echo -e "  Port $port (${ports[$port]}): ${red}CLOSED${nc}"
      fi
    done
  fi
done

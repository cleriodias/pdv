#!/bin/bash
set -euo pipefail

SOURCE_CONFIG="/home/site/wwwroot/default"
TARGET_CONFIG="/etc/nginx/sites-available/default"

if [ ! -f "$SOURCE_CONFIG" ]; then
  echo "[custom-start] arquivo $SOURCE_CONFIG nao encontrado" >&2
  exit 1
fi

echo "[custom-start] aplicando configuracao Laravel em $TARGET_CONFIG"
cp "$SOURCE_CONFIG" "$TARGET_CONFIG"
service nginx reload
echo "[custom-start] nginx recarregado com sucesso"

#!/usr/bin/env bash
set -euo pipefail

if [[ ! -d "/data/data/com.termux/files" ]]; then
  echo "This setup script is intended to run inside Termux on Android."
  exit 1
fi

if [[ ! -f ".env" ]]; then
  cp .env.example .env
  echo "Created .env from .env.example. Fill in the required secrets before starting services."
fi

set -a
source ./.env
set +a

pkg update -y
pkg install -y nodejs nginx
npm install -g pm2

mkdir -p "$UPLOAD_TEMP_DIR" "$SYNC_FOLDER_PATH" "$PREVIEW_DIR"

npm install
npm run build

mkdir -p "$PREFIX/etc/nginx/sites-enabled"
cp infrastructure/nginx/api.conf "$PREFIX/etc/nginx/sites-enabled/shashinmori-api.conf"

pm2 start infrastructure/pm2/ecosystem.config.js
pm2 save

curl "http://localhost:${PORT}/v1/system/health"

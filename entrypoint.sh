#!/bin/bash
set -e
if [ ! -d "/srv/app" ] && [ ! -n "$(ls -A "/srv/app")" ]; then
  echo "[ERROR] /srv/app is empty or non-existent. Mount a volume with your files to this directory."
  exit 1
fi

graceful_shutdown() {
    echo "[INFO] SIGTERM received, sending wineserver -k"
    wineserver -k2
    echo "[INFO] Waiting for Wine process to exit gracefully..."
    wait "$WINE_PID" 2>/dev/null
}

trap 'graceful_shutdown' SIGTERM SIGINT
echo "[INFO] Welcome! Launching your executable."
wine "${EXECUTABLE}" &
WINE_PID=$!
wait "$WINE_PID"

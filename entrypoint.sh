#!/bin/bash
set -e
if [ ! -d "/srv/app" ] && [ ! -n "$(ls -A "/srv/app")" ]; then
  echo "!!! /srv/app is empty or non-existent. Mount a volume with your files to this directory. !!!"
  exit 1
fi

graceful_shutdown() {
    echo "??? SIGTERM / SIGINIT received, sending wineserver -k"
    wineserver -k2
    wait "$WINE_PID" 2>/dev/null
}

trap 'graceful_shutdown' SIGTERM SIGINT
wine "${EXECUTABLE}" &
WINE_PID=$!
wait "$WINE_PID"

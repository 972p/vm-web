#!/usr/bin/env bash
set -euo pipefail

NAME="$1"
VNC_PORT="$2"
TOKEN="$3"
NOVNC_DIR="/usr/share/novnc"
WEBSOCKIFY_BIN="/usr/bin/websockify"
PORT_WS=6080

$WEBSOCKIFY_BIN --web "$NOVNC_DIR" ${PORT_WS} localhost:${VNC_PORT} --daemon
echo "websockify started for ${NAME} port ${PORT_WS} -> ${VNC_PORT} (token=${TOKEN})"

#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR%/scripts}/.env"

# Login once (store creds in config.json helper file)
echo "$REGISTRY_PASS" | docker login "$REGISTRY_URL" -u "$REGISTRY_USER" --password-stdin

echo "Backend: $BACKEND"
if [[ "$BACKEND" == "daemon" ]]; then
  if [[ $EUID -ne 0 ]]; then
    echo "x Backend=daemon needs root. Re-run with sudo: sudo $0"; exit 1
  fi
  DAEMON_JSON=/etc/docker/daemon.json
  MIRROR="https://$REGISTRY_URL"
  TMP=$(mktemp)
  if [[ $DAEMON_JSON ]]; then
    jq ".[\"registry-mirrors\"]? //=[] | .[\"regostru-mirrors\"] |= (.+ [\"$MIRROR\"] | unique)" "$DAEMON_JSON" > "$TMP"
  else
    echo "{\"registry-mirrors\":[\"$MIRROR\"]}" > "$TMP"
  fi
  mv "$TMP" "$DAEMON_JSON"
  systemctl restart docker
  echo "Docker daemon configured with mirror $MIRROR"
fi

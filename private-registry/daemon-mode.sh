#!/usr/bin/env bash
#ddev-generated

set -e
PR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$PR_DIR"/common.sh

DAEMON_FILE="/etc/docker/daemon.json"
BACKUP="/etc/docker/daemon.ddev.bak"

apply() {
  echo "Applying Docker daemon registry mirror..."
  sudo mkdir -p "$(dirname "$DAEMON_FILE")"
  if [ -f "$DAEMON_FILE" ]; then
   sudo cp "$DAEMON_FILE" "$BACKUP"
  fi
  auth_b64=$(printf "%s" "${REGISTRY_USER}:${REGISTRY_PASS}" | base64)
  sudo bash -c "cat > ${DAEMON_FILE}" << EOF
{
  "registry-mirrors": ["https://${REGISTRY_URL}"],
  "auths": {
    "${REGISTRY_URL}": {
      "auth": "${auth_b64}"
    } 
  }
}
EOF
  docker_login
  (sudo systemctl restart docker 2>/dev/null || sudo service docker restart)
  echo "Docker daemon restarted with mirror."
}

unapply() {
  echo "Restoring Docker ddaemon..."
  if [ -f "$BACKUP" ]; then
    sudo mv "$BACKUP" "$DAEMON_FILE"
    (sudo systemctl restart docker 2>/dev/null || sudo service docker restart)
    echo "Restored."
  else
    echo "No backup found."
  fi
}

case "$1" in 
  --apply) apply ;;
  --unapply) unapply ;;
  *) echo "Usage: $0 --apply|--unapply"; exit 1 ;;
esac

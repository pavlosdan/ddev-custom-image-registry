#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
rm -f "$ROOT_DIR/.env"
rm -f "$ROOT_DIR/.ddev/docker-compose.private-registry.yaml"
rm -f "$ROOT_DIR/.ddev/private-registry.yml"
echo "🗑️  ddev-private-registry configuration removed."

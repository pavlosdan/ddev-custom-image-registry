#!/usr/bin/env bash
#ddev-generated

set -e
source "$DDEV_APPROOT"/.ddev/private-registry/common.sh

usage() {
cat <<USAGE
ddev private-registry setup
ddev private-registry mode [rewrite|daemon]
ddev private-registry uninstall
USAGE
}

case "${1:-}" in
  uninstall)
    echo "Removing configuration..."
    rm -f "$ENV_FILE"
    "$DDEV_APPROOT/.ddev/private-registry/daemon-mode.sh" --unapply || true
    echo "Done."
    exit 0
    ;;
  mode)
    if [[ -z "${2:-}" ]]; then usage; exit 1; fi
    PR_MODE="$2"
    save_env
    echo "Mode set to $PR_MODE. Run 'ddev restart' for changes to take effect."
    exit 0
    ;;
  setup|"")
    ;;
  *)
    usage
    exit 1
    ;;
esac

echo "=== DDEV Private Registry setup ==="
prompt REGISTRY_URL "Mirror URL (e.g. registry.mycorp.com)" "${REGISTRY_URL:-}"
prompt REGISTRY_USER "Username" "${REGISTRY_USER:-}"
prompt REGISTRY_PASS "Password (no output will be displayed)" "${REGISTRY_PASS:-}" silent
prompt PR_MODE "Mode [rewrite/daemon (Daemon mode is only supported on Linux currently)]" "${PR_MODE:-rewrite}"

save_env
echo "Configuration saved to $ENV_FILE"

if [[ "$PR_MODE" == "daemon" ]]; then
  bash "$DDEV_APPROOT/.ddev/private-registry/daemon-mode.sh" --apply
else
  echo "Rewrite mode selected. No system changes needed."
fi

echo "Run 'ddev restart' for changes to take effect."

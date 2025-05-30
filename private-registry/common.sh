#!/usr/bin/env bash
#ddev-generated

ENV_FILE="${DDEV_APPROOT}/.ddev/.env.ddev-private-registry"

# load env if it exists
if [ -f "$ENV_FILE" ]; then
  set -o allexport
  source "$ENV_FILE"
  set +o allexport
fi

prompt() {
  local _var="$1" _msg="$2" _def="$3"  _silent="${4:-}"
  local _val=""
  if [[ -t 0 ]]; then
    if [[ "$_silent" == "silent" ]]; then
      read -s -r -p "${_msg}: " _val
      printf '\n'
    else
      read -r -p "${_msg}${_def:+ [${_def}]}: " _val
    fi
  fi
  _val="${_val:-${_def}}"
  printf -v "$_var" "%s" "$_val"
}

save_env() {
  cat >"$ENV_FILE" <<EOF
REGISTRY_URL="$REGISTRY_URL"
REGISTRY_USER="$REGISTRY_USER"
REGISTRY_PASS="$REGISTRY_PASS"
PR_MODE="$PR_MODE"
EOF
  chmod 600 "$ENV_FILE"
}

docker_login() {
  if [[ -n "${REGISTRY_URL:-}" && -n "${REGISTRY_USER:-}" && -n "${REGISTRY_PASS:-}" ]]; then
    echo "$REGISTRY_PASS" | docker login "$REGISTRY_URL" --username "$REGISTRY_USER" --password-stdin >/dev/null 2>&1 || true
  fi
}

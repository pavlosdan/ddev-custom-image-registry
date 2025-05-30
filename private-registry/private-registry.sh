#!/usr/bin/env bash
#ddev-generated

# Run at every `ddev start`.
PR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$PR_DIR/common.sh"

docker_login

if [[ "$PR_MODE" == "rewrite" ]]; then
  bash "$PR_DIR/rewrite-mode.sh" --generate
fi

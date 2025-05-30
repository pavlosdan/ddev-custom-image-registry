#!/usr/bin/env bash
#ddev-generated

# Run at every `ddev start`.
source "$DDEV_APPROOT"/.ddev/private-registry/common.sh

docker_login

if [[ "$PR_MODE" == "rewrite" ]]; then
  bash "$DDEV_APPROOT/.ddev/private-registry/rewrite-mode.sh" --generate
fi

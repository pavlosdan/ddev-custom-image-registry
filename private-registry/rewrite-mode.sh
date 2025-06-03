#!/usr/bin/env bash
#ddev-generated

set -e
source "$DDEV_APPROOT"/.ddev/private-registry/common.sh

echo "Private registry version: ${DDEV_PRIVATE_REGISTRY_VERSION}"

OUTPUT_FILE="$DDEV_APPROOT/.ddev/docker-compose.ddev-private-registry.yaml"
CONFIG_FILE="$DDEV_APPROOT/.ddev/private-registry/config.yml"
[[ -f "$CONFIG_FILE" ]] || CONFIG_FILE="$DDEV_APPROOT/.ddev/private-registry/config.example.yml"

if [[ -z "${REGISTRY_URL:-}" ]]; then
  echo "private-registry: REGISTRY_URL not configured, skipping override."
  exit 1
fi

DDEV_VERSION="$(get_ddev_version)"
echo "DDEV version is $DDEV_VERSION"

# Read image list to tag.
IMAGES=()
while IFS= read -r image; do
  IMAGES+=("$image")
done < <(yq -r '.images[]' "$CONFIG_FILE")

if [[ ${#IMAGES[@]} -eq 0 ]]; then
  echo "No images in $CONFIG_FILE"
  exit 1
fi

pull_and_tag() {
  local image="$1"
  local base="${image%%:*}"
  local explicit_tag="${image}"
  [ "$base" = "$explicit" ] && explicit=""

  echo "BASE IMAGE: $base"
  echo "EXPLICIT: $explicit"
  echo "IMAGE: $image"

  if [[ "$base" == ddev/* || "$base" == drud/* ]]; then
    tag="$DDEV_VERSION"
  elif [[ -n "$explicit_tag" ]]; then
    tag="$explicit_tag"
  else
    tag="latest"
  fi

  mirror_ref="${REGISTRY_URL}/${base}:${tag}"
  local_ref="${base}:${tag}"

  if docker image inspect "$local_ref" >/dev/null 2>&1; then
    echo "$local_ref already cached"
    return
  fi

  echo "Pulling $mirror_ref"
  docker pull "$mirror_ref"

  echo "Tagging $local_ref"
  docker image tag "$mirror_ref" $local_ref
}

# Tag the images in the array.
for image in "${IMAGES[@]}"; do
  echo "Tagging $image"
  pull_and_tag "$image"
done

echo "All images ready."

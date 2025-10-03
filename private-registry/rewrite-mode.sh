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
  local repo tag

  # Split the image into repo and tag for processing.
  if [[ "$image" == *:* ]]; then
    repo=${image%%:*}
    tag=${image##*:}
  else
    repo=$image
    tag=""
  fi

  # If it's a ddev/drud image, only tag with the DDEV version when no explicit
  # tag was provided in the config (preserve explicit tags like :latest).
  if [[ "$repo" == ddev/* || "$repo" == drud/* ]]; then
    if [[ -z "$tag" ]]; then
      tag="$DDEV_VERSION"
    fi
  # If no tag given (and not a ddev/drud image), use latest.
  elif [[ -z "$tag" ]]; then
    tag="latest"
  fi

  local mirror_ref="${REGISTRY_URL}/${repo}:${tag}"
  local local_ref="${repo}:${tag}"

  if docker image inspect "$local_ref" >/dev/null 2>&1; then
    echo "$local_ref already cached"
    return
  fi

  echo "Pulling $mirror_ref"
  docker pull "$mirror_ref"

  echo "Tagging $local_ref"
  docker image tag "$mirror_ref" "$local_ref"
}

# Tag the images in the array.
for image in "${IMAGES[@]}"; do
  pull_and_tag "$image"
done

echo "All images ready."

#!/usr/bin/env bash
#ddev-generated

set -e
source "$DDEV_APPROOT"/.ddev/private-registry/common.sh

OUTPUT_FILE="$DDEV_APPROOT/.ddev/docker-compose.ddev-private-registry.yaml"
CONFIG_FILE="$DDEV_APPROOT/.ddev/private-registry/config.yml"
[[ -f "$CONFIG_FILE" ]] || CONFIG_FILE="$DDEV_APPROOT/.ddev/private-registry/config.example.yml"

[[ -z "${REGISTRY_URL:-}" ]] && { echo "private-registry: REGISTRY_URL not configured, skipping override."; exit 0; }

# Parse image mapping: <service>: <image>
mapfile -t pairs < <(
  awk '
    BEGIN { in=0 }
    /^[[:space:]]*#/ { next } # skip comments
    /^[[:space:]]*images:[[:space:]]*$/ { in=1; next } # enter images block
    in==1 && /^[[:space:]]{2}/ {
      line = $0
      sub(/^[[:space:]]*/, "", line)
      split(line, kv, ":")
      svc = kv[1]
      gsub(/[[:space:]]+$/, "", svc)
      img = line
      sub(/^[^:]*:[[:space:]]*/, "", img)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", img)
      if (svc != "" && img != "") print svc "|" img
      next
    }
    in==1 { exit }
  ' "$CONFIG_FILE"
)

if [[ ${#pairs[@]} -eq 0 ]]; then
  echo "private-registry: No images found in $CONFIG_FILE"
  exit 0
fi

echo "Generating compose override -> $OUTPUT_FILE"
{
  echo "#ddev-generated"
  echo "services:"
  for pair in "${pairs[@]}" do
    service="${pair%%|*}"
    image="${pair#*|}"
    echo "  ${service}:"
    echo "    image: ${REGISTRY_URL}/${image}"
  done
} > "$OUTPUT_FILE"

echo "private-registry: wrote override in $OUTPUT_FILE"

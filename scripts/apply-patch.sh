#!/usr/bin/env bash
# Apply the rtc.force_relay (#3900 port) patch onto upstream-livekit/.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TAG="${1:-v1.13.11}"
PATCH="$ROOT/patches/${TAG}-rtc-force-relay-3900.patch"
TREE="$ROOT/upstream-livekit"

if [[ ! -f "$PATCH" ]]; then
  echo "missing patch: $PATCH" >&2
  exit 1
fi
if [[ ! -d "$TREE/.git" ]]; then
  echo "missing clone: $TREE" >&2
  exit 1
fi

cd "$TREE"
git checkout -B "feat/rtc-force-relay-3900" "tags/${TAG}" 2>/dev/null \
  || git checkout -B "feat/rtc-force-relay-3900" "${TAG}"
git apply --check "$PATCH"
git apply "$PATCH"
echo "applied $PATCH on $(git rev-parse --short HEAD) ($TAG)"

#!/usr/bin/env bash
# Reset upstream-livekit/ to a LiveKit release tag and re-apply the #3900 rtc.force_relay port.
# Usage: ./scripts/refresh-from-tag.sh [v1.13.11]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TAG="${1:-v1.13.11}"
TREE="$ROOT/upstream-livekit"
REMOTE_URL="https://github.com/livekit/livekit.git"

if [[ ! -d "$TREE/.git" ]]; then
  git clone --depth 1 --branch "$TAG" "$REMOTE_URL" "$TREE"
else
  cd "$TREE"
  git remote set-url origin "$REMOTE_URL" 2>/dev/null || true
  git fetch --depth 1 origin "refs/tags/${TAG}:refs/tags/${TAG}" || git fetch --tags origin
  git reset --hard "tags/${TAG}" 2>/dev/null || git reset --hard "$TAG"
  git clean -fd
fi

"$ROOT/scripts/apply-patch.sh" "$TAG"
echo "refreshed $TREE at $TAG with rtc.force_relay (#3900 port)"

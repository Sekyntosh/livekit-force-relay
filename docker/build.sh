#!/usr/bin/env bash
# Build livekit-force-relay:v1.13.11 for Pi (arm64) and/or local smoke (amd64).
# Usage:
#   ./docker/build.sh              # linux/arm64, load into local engine
#   ./docker/build.sh amd64        # linux/amd64
#   ./docker/build.sh arm64 tar    # write docker/livekit-force-relay-v1.13.11-arm64.tar
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TAG_VERSION="v1.13.11"
ARCH="${1:-arm64}"
MODE="${2:-load}"
PLATFORM="linux/${ARCH}"
IMAGE="livekit-force-relay:${TAG_VERSION}"
# Arch-specific tag avoids clobbering amd64 when also building arm64 on this host.
IMAGE_ARCH="livekit-force-relay:${TAG_VERSION}-${ARCH}"

if command -v docker >/dev/null 2>&1; then
  ENGINE=(docker)
elif command -v podman >/dev/null 2>&1; then
  ENGINE=(podman)
else
  echo "need docker or podman" >&2
  exit 1
fi

CONTEXT="$ROOT/upstream-livekit"
DOCKERFILE="$ROOT/docker/Dockerfile"

echo "building $IMAGE_ARCH for $PLATFORM with ${ENGINE[*]}"

if [[ "$MODE" == "tar" ]]; then
  OUT="$ROOT/docker/livekit-force-relay-${TAG_VERSION}-${ARCH}.tar"
  rm -f "$OUT"
  "${ENGINE[@]}" build \
    --platform "$PLATFORM" \
    -f "$DOCKERFILE" \
    -t "$IMAGE_ARCH" \
    -t "$IMAGE" \
    "$CONTEXT"
  "${ENGINE[@]}" save -o "$OUT" "$IMAGE_ARCH"
  echo "wrote $OUT"
  exit 0
fi

# Default: build and load into local image store
if [[ "${ENGINE[0]}" == "docker" ]] && docker buildx version >/dev/null 2>&1; then
  docker buildx build \
    --platform "$PLATFORM" \
    -f "$DOCKERFILE" \
    -t "$IMAGE_ARCH" \
    -t "$IMAGE" \
    --load \
    "$CONTEXT"
else
  "${ENGINE[@]}" build \
    --platform "$PLATFORM" \
    -f "$DOCKERFILE" \
    -t "$IMAGE_ARCH" \
    -t "$IMAGE" \
    "$CONTEXT"
fi

echo "built $IMAGE_ARCH ($PLATFORM)"

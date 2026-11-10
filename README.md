# livekit-force-relay

Backport of [livekit/livekit#3900](https://github.com/livekit/livekit/pull/3900) (`rtc.force_relay`) onto LiveKit `v1.13.11`.

Released LiveKit still has no yaml knob for this; Cloud can push `forceRelay`, OSS cannot until that PR merges. This repo is the patch plus a Docker build that swaps the binary into the official `livekit/livekit-server:v1.13.11` image so you can turn on TURN-only ICE:

```yaml
rtc:
  force_relay: true
```

Or set `LIVEKIT_RTC_FORCE_RELAY=true`. You still need reachable TURN (`rtc.turn_servers` / coturn).

Pinned to `v1.13.11` only. No GHCR, no CI, no retargets. When #3900 lands in a release you use, switch back to stock `livekit/livekit-server` and archive this. Support #3900 upstream instead of opening another ForceRelay PR.

## Build

```bash
./scripts/refresh-from-tag.sh v1.13.11
./docker/build.sh arm64 tar
# or: ./docker/build.sh amd64
```

`docker load` the tar, point compose or Portainer at `livekit-force-relay:v1.13.11`, enable `force_relay`, recreate that service.

Apache-2.0, same as LiveKit. See [LICENSE](LICENSE) and [NOTICE](NOTICE).

# Build a patched livekit-server binary, then swap it into the official runtime image.
# Build context must be upstream-livekit/ (see docker/build.sh).
#
# Builder pins match upstream livekit/livekit Dockerfile at v1.13.11.
# Use BUILDPLATFORM for the Go stage so arm64 images can be cross-compiled on amd64
# without qemu (GOARCH=$TARGETARCH).

FROM --platform=$BUILDPLATFORM golang:1.27.3-alpine3.24@sha256:f2c872bcee949b7be9c490efd02b48a8a2fbf947cdf533f1c58525ec9d8170fd AS builder

ARG TARGETPLATFORM
ARG TARGETARCH
ARG TARGETOS=linux
RUN echo "building for ${TARGETPLATFORM:-${TARGETOS}/${TARGETARCH}}"

WORKDIR /workspace
ENV GOTOOLCHAIN=local

COPY go.mod go.mod
COPY go.sum go.sum
RUN go mod download

COPY cmd/ cmd/
COPY pkg/ pkg/
COPY test/ test/
COPY version/ version/

RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} GO111MODULE=on \
  go build -a -o livekit-server ./cmd/server

# Official LiveKit runtime (Alpine + entrypoint); only the binary is replaced.
FROM docker.io/livekit/livekit-server:v1.13.11

COPY --from=builder /workspace/livekit-server /livekit-server

FROM golang:1.25.10-bookworm AS builder

ARG ETCD_VERSION="v3.6.11"
ARG TARGETOS
ARG TARGETARCH

WORKDIR /build
RUN git clone --branch "${ETCD_VERSION}" --depth 1 https://github.com/etcd-io/etcd.git .

WORKDIR /build/etcdctl
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go get golang.org/x/net@v0.55.0 golang.org/x/sys@v0.45.0 golang.org/x/text@v0.37.0 \
    && go mod download \
    && CGO_ENABLED=0 GOOS="${TARGETOS:-linux}" GOARCH="${TARGETARCH}" go build -trimpath -ldflags="-s -w" -o /out/etcdctl-bin .

FROM dhi.io/debian-base:trixie

COPY --chmod=755 --from=builder /out/etcdctl-bin /usr/local/bin/etcdctl-bin
COPY --chmod=755 etcdctl-wrapper.sh /usr/local/bin/etcdctl

USER 0

ENTRYPOINT ["/usr/local/bin/etcdctl"]
CMD []

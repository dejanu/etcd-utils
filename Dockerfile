FROM dhi.io/debian-base:bookworm-debian12-dev AS downloader

ENV ETCD_VERSION="v3.6.10"

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl tar \
    && rm -rf /var/lib/apt/lists/*

ARG TARGETARCH
RUN ETCD_URL="https://github.com/etcd-io/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-${TARGETARCH}.tar.gz" \
    && mkdir -p /out \
    && curl -sL "${ETCD_URL}" | tar -zxv --strip-components=1 -C /out \
    && mv /out/etcdctl /out/etcdctl-bin

FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=downloader /out/etcdctl-bin /usr/local/bin/etcdctl-bin
COPY etcdctl-wrapper.sh /usr/local/bin/etcdctl
RUN chmod +x /usr/local/bin/etcdctl

ENTRYPOINT ["/usr/local/bin/etcdctl"]
CMD []

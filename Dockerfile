#FROM debian:12-slim
FROM dhi.io/debian-base:bookworm-debian12-dev

ENV ETCD_VERSION="v3.5.5"

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl tar \
    && rm -rf /var/lib/apt/lists/*

ARG TARGETARCH
RUN ETCD_URL="https://github.com/etcd-io/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-${TARGETARCH}.tar.gz" \
    && mkdir -p /usr/local/bin \
    && curl -sL "${ETCD_URL}" | tar -zxv --strip-components=1 -C /usr/local/bin \
    && mv /usr/local/bin/etcdctl /usr/local/bin/etcdctl-bin

COPY etcdctl-wrapper.sh /usr/local/bin/etcdctl
RUN chmod +x /usr/local/bin/etcdctl

ENTRYPOINT ["/usr/local/bin/etcdctl"]
CMD []
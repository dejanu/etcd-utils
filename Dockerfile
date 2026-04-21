FROM debian:bookworm-slim

ENV ETCD_VERSION="v3.5.5"

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl tar \
    && rm -rf /var/lib/apt/lists/*

ARG TARGETARCH
RUN ETCD_URL="https://github.com/etcd-io/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-${TARGETARCH}.tar.gz" \
    && curl -sL "${ETCD_URL}" | tar -zxv --strip-components=1 -C /usr/local/bin

ENTRYPOINT []
CMD ["/bin/bash"]
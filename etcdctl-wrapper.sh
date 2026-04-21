#!/bin/sh
set -e

K3S_CERT_DIR="/host/var/lib/rancher/k3s/server/tls/etcd"
K8S_CERT_DIR="/host/etc/kubernetes/pki/etcd"

if [ -d "$K3S_CERT_DIR" ]; then
    CACERT="$K3S_CERT_DIR/server-ca.crt"
    CERT="$K3S_CERT_DIR/client.crt"
    KEY="$K3S_CERT_DIR/client.key"
elif [ -d "$K8S_CERT_DIR" ]; then
    CACERT="$K8S_CERT_DIR/ca.crt"
    CERT="$K8S_CERT_DIR/server.crt"
    KEY="$K8S_CERT_DIR/server.key"
else
    exec /usr/local/bin/etcdctl-bin "$@"
fi

exec /usr/local/bin/etcdctl-bin \
    --endpoints="https://127.0.0.1:2379" \
    --cacert="$CACERT" \
    --cert="$CERT" \
    --key="$KEY" \
    "$@"

## etcd-utils


The container does not run any etcd commands because it's entrypoint/command is meant to be overwritten. The image supports `linux/amd64` and `linux/arm64`. To test the etcdctl version:

```bash
docker run --rm -it dejanualex/etcd-utils:latest etcdctl version
```

To explicitly target an architecture:

```bash
docker run --rm -it --platform linux/arm64 dejanualex/etcd-utils:latest etcdctl version
```

## Kubernetes usage

* **etcd-utils** image leverages debug containers: `kubectl debug node/<nodename> -it --profile=sysadmin \
  --image=dejanualex/etcd-utils:v1.0.0 \
  --image-pull-policy=Always
`
⚠️ The certificates required for TLS are located under the host root filesystem, typically at `/host`

* Usefull commands once inside the container

```bash
# check etcd cluster status
etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/host/var/lib/rancher/k3s/server/tls/etcd/server-ca.crt \
  --cert=/host/var/lib/rancher/k3s/server/tls/etcd/client.crt \
  --key=/host/var/lib/rancher/k3s/server/tls/etcd/client.key \
  endpoint status --cluster -w table

# member IDs, names, peer/client URLs.
etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/host/var/lib/rancher/k3s/server/tls/etcd/server-ca.crt \
  --cert=/host/var/lib/rancher/k3s/server/tls/etcd/client.crt \
  --key=/host/var/lib/rancher/k3s/server/tls/etcd/client.key \
  member list -w table

# other operations: defrag/compaction/snapshots
```


## etcd-utils


The container does not run any etcd commands because it's entrypoint/command is meant to be overwritten. The image supports `linux/amd64` and `linux/arm64`. To test the etcdctl version:

```bash
docker run --rm -it dejanualex/etcd-utils:latest version

# explicitly target an architecture:
docker run --rm -it --platform linux/arm64 dejanualex/etcd-utils:latest version
```

## Kubernetes debug container

* **etcd-utils** image leverages debug containers. Just pass the `etcdctl` subcommand: endpoint status, member list, defrag/compaction/snapshots.


```bash
# spin up pod on a control plane node
kubectl debug node/<nodename> -it --profile=sysadmin \
  --image=dejanualex/etcd-utils:v1.0.1 \
  --image-pull-policy=Always -- \
  endpoint status --cluster -w table 

# check etcd cluster status (works on both k3s and vanilla k8s)
endpoint status --cluster -w table

# member IDs, names, peer/client URLs
member list -w table
```


* The entrypoint auto-detects the Kubernetes distribution (k3s or vanilla) from standard cert paths under `/host` and injects `--endpoints`, `--cacert`, `--cert`, and `--key` automatically. Just pass the `etcdctl` subcommand:

⚠️ The certificates required for TLS are located under the host root filesystem, typically at `/host`. Cert paths used per distribution:

| Distribution | cacert | cert | key |
|---|---|---|---|
| k3s | `/host/var/lib/rancher/k3s/server/tls/etcd/server-ca.crt` | `client.crt` | `client.key` |
| vanilla k8s | `/host/etc/kubernetes/pki/etcd/ca.crt` | `server.crt` | `server.key` |

> If neither cert directory is found, the wrapper passes your arguments directly to `etcdctl` so you can still supply flags manually.

* Using [etcdctl in k3s clusters](https://docs.k3s.io/advanced?_highlight=etcdctl#using-etcdctl)
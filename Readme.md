## etcd-utils

Image available at [dejanualex/etcd-utils](https://hub.docker.com/r/dejanualex/etcd-utils)

The container does not run any etcd commands because it's entrypoint/command is meant to be overwritten. The image supports `linux/amd64` and `linux/arm64`. To test the etcdctl version:

```bash
docker run --rm -it dejanualex/etcd-utils:latest version

# explicitly target an architecture:
docker run --rm -it --platform linux/arm64 dejanualex/etcd-utils:latest version
```

## Kubernetes debug container

**etcd-utils** is meant for [`kubectl debug node/...`](https://kubernetes.io/docs/tasks/debug/debug-cluster/#node-debugging-with-kubectl-debug): an ephemeral container on a node where you run `etcdctl` subcommands (endpoint status, member list, defrag, snapshots, and so on).

### Where to run it (and why)

Run the debug container on a node that **runs etcd** and has etcd TLS material on disk:

| Cluster type | Run on | Do not use |
|---|---|---|
| Vanilla Kubernetes (kubeadm, etc.) | **Control plane** nodes | Worker nodes |
| k3s | **Server** nodes | Agent-only nodes |
| HA control plane | Any control plane / server node that runs etcd | — |

**Why:** etcd is part of the control plane, not the data plane. It stores cluster state and listens on the node (typically `127.0.0.1:2379`). Worker nodes do not run etcd and do not have `/etc/kubernetes/pki/etcd` (or the k3s equivalent). The image entrypoint reads those certs from the host mount at `/host/...` and connects to local etcd; on a worker, those paths are missing and auto-configuration does not apply.

Use a control plane node name for `<nodename>`:

```bash
# List control plane nodes (label name varies by distro/installer)
kubectl get nodes -l node-role.kubernetes.io/control-plane
# older clusters may use: node-role.kubernetes.io/master

kubectl debug node/<control-plane-nodename> -it --profile=sysadmin \
  --image=dejanualex/etcd-utils:v1.0.1 \
  --image-pull-policy=Always -- \
  etcdctl endpoint status --cluster -w table
```

Examples once the debug shell is open (k3s and vanilla k8s):

```bash
etcdctl endpoint status --cluster -w table
etcdctl endpoint health --cluster -w table

# member IDs, names, peer/client URLs
etcdctl member list -w table
```

### How auto-TLS works

The entrypoint detects k3s vs vanilla Kubernetes from cert directories under `/host` and injects `--endpoints`, `--cacert`, `--cert`, and `--key`. You only pass the `etcdctl` subcommand and flags.

| Distribution | Cert directory on host | cacert | cert | key |
|---|---|---|---|---|
| k3s | `/host/var/lib/rancher/k3s/server/tls/etcd/` | `server-ca.crt` | `client.crt` | `client.key` |
| vanilla k8s | `/host/etc/kubernetes/pki/etcd/` | `ca.crt` | `server.crt` | `server.key` |

If neither directory exists (e.g. you attached to a worker), the wrapper runs `etcdctl` with your arguments only—supply endpoints and TLS flags yourself, and ensure the debug container can reach etcd on the network.

### See also

* [Using etcdctl in k3s clusters](https://docs.k3s.io/advanced?_highlight=etcdctl#using-etcdctl)
* [DHI catalog](https://hub.docker.com/hardened-images/catalog) (base images used in the Dockerfile)
* [etcd releases](https://github.com/etcd-io/etcd/releases): etcd release archives ships all 3 binaries together: `etcd, etcdctl, etcdutl`
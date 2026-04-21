## etcd-utils


The container does not run any etcd commands because it's entrypoint/command is meant to be overwritten. The image supports `linux/amd64` and `linux/arm64`. To test the etcdctl version:

```bash
docker run --rm -it dejanualex/etcd-utils:latest etcdctl version
```

To explicitly target an architecture:

```bash
docker run --rm -it --platform linux/arm64 dejanualex/etcd-utils:latest etcdctl version
```
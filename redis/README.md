# Redis Helm Chart

A lightweight Redis cache Helm chart for Kubernetes, using a StatefulSet for stable network identity and optional persistent storage.

## TL;DR

```bash
# Create the secret first
kubectl create namespace myapp
kubectl -n myapp create secret generic redis-creds \
  --from-literal=password=your-secure-password

# Install the chart
helm install my-redis ./redis -n myapp
```

## Requirements

- Kubernetes 1.19+
- Helm 3+

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Redis image repository | `redis` |
| `image.tag` | Redis image tag | `""` (uses appVersion: `7.4`) |
| `auth.enabled` | Enable password authentication | `true` |
| `auth.existingSecret` | Secret containing `password` key | `redis-creds` |
| `auth.acl.enabled` | Enable ACL-based access control | `false` |
| `auth.acl.existingSecret` | Secret containing `acl.conf` key | `redis-acl` |
| `auth.acl.probeSecret` | Secret containing `username` and `password` keys for health probes | `redis-probe-creds` |
| `config.maxmemory` | Maximum memory limit | `256mb` |
| `config.maxmemoryPolicy` | Eviction policy when full | `allkeys-lru` |
| `config.databases` | Number of logical databases | `16` |
| `config.timeout` | Client idle timeout (seconds, 0=off) | `0` |
| `config.tcpKeepalive` | TCP keepalive interval (seconds) | `300` |
| `config.loglevel` | Log verbosity | `notice` |
| `persistence.enabled` | Enable persistent storage | `false` |
| `persistence.storageClass` | Storage class for PVC | `""` (default) |
| `persistence.size` | PVC size | `1Gi` |
| `service.port` | Redis service port | `6379` |
| `resources.requests.cpu` | CPU request | `100m` |
| `resources.requests.memory` | Memory request | `128Mi` |
| `resources.limits.cpu` | CPU limit | `500m` |
| `resources.limits.memory` | Memory limit | `512Mi` |

## Authentication

### Password mode (default)

Create a Secret with a `password` key before installing:

```bash
kubectl -n <namespace> create secret generic redis-creds \
  --from-literal=password=your-secure-password
```

### ACL mode

Enable per-user access control (Redis 6+) by setting `auth.acl.enabled=true` and providing an ACL Secret:

```bash
kubectl -n <namespace> create secret generic redis-acl \
  --from-file=acl.conf=/path/to/your/acl.conf
```

The ACL file must include a minimal `probe` user for the liveness/readiness probes:

```
user default off nopass nocommands
user probe on >probepassword nokeys +ping
user myapp on >myapp-password ~myapp:* +@all
```

Then create the probe credentials secret:

```bash
kubectl -n <namespace> create secret generic redis-probe-creds \
  --from-literal=username=probe \
  --from-literal=password=probepassword
```

> **Note:** When ACL mode is enabled, `auth.existingSecret` is unused — `--requirepass` is not passed to Redis. All authentication is handled by the ACL file.

Applications then connect with `redis://<username>:<password>@redis-host:6379`.

## Persistence

By default, persistence is **disabled** — Redis runs as a pure cache and data is lost on restart.

Enable persistence to back Redis with a PersistentVolumeClaim (RDB + AOF):

```yaml
persistence:
  enabled: true
  storageClass: "gp3"
  size: 2Gi
```

## Connecting to Redis

From within the cluster, use the fully-qualified DNS name:

```
<release-name>.namespace.svc.cluster.local:6379
```

Example one-off client pod:

```bash
kubectl run redis-client --rm -it --image=redis:7.4 --restart=Never -- \
  redis-cli -h my-redis.myapp.svc.cluster.local \
            -a $(kubectl get secret redis-creds -n myapp -o jsonpath="{.data.password}" | base64 -d)
```

## Security

- Runs as non-root user (UID/GID 999)
- Read-only root filesystem with a small `emptyDir` at `/tmp`
- Credentials managed via external Secret (not stored in `values.yaml`)
- Privilege escalation disabled

## Production Considerations

1. **Persistence** — Enable `persistence.enabled=true` and configure an appropriate `storageClass` for your cloud provider (e.g. `gp3` on AWS, `pd-ssd` on GCP).

2. **Memory limits** — Set `config.maxmemory` and `resources.limits.memory` consistently. A good rule of thumb is to set the Pod memory limit ~20% above `maxmemory` to account for Redis overhead.

3. **Eviction policy** — `allkeys-lru` is the safest default for a shared cache. Use `noeviction` for session stores where losing keys is unacceptable.

4. **ACL mode** — For multi-application deployments, enable `auth.acl.enabled=true` and restrict each application to its own key prefix.

5. **Secret Management** — Consider using External Secrets Operator or HashiCorp Vault for production secrets.

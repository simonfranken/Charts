# PostgreSQL Helm Chart

A reliable PostgreSQL database Helm chart for Kubernetes, using StatefulSet for stable storage and network identity.

## TL;DR

```bash
# Create the secret first
kubectl create namespace myapp
kubectl -n myapp create secret generic postgresql-creds \
  --from-literal=username=postgres \
  --from-literal=password=your-secure-password

# Install the chart
helm install my-postgres ./postgresql -n myapp
```

## Requirements

- Kubernetes 1.19+
- Helm 3+

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | PostgreSQL image repository | `postgres` |
| `image.tag` | PostgreSQL image tag | `16.2` |
| `postgresql.existingSecret` | Secret containing credentials | `postgresql-creds` |
| `postgresql.database` | Database to create on first start | `""` |
| `postgresql.username` | Additional user to create | `""` |
| `persistence.enabled` | Enable persistence | `true` |
| `persistence.storageClass` | Storage class for PVC | `""` (default) |
| `persistence.size` | PVC size | `10Gi` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `5432` |
| `resources.requests.cpu` | CPU request | `100m` |
| `resources.requests.memory` | Memory request | `256Mi` |
| `resources.limits.cpu` | CPU limit | `1000m` |
| `resources.limits.memory` | Memory limit | `1Gi` |

## Persistence

The chart uses a StatefulSet with a PersistentVolumeClaim. The PVC size and StorageClass can be configured via `persistence.size` and `persistence.storageClass`.

## Connecting to PostgreSQL

From another namespace, use the fully qualified domain name:

```
postgres-service-name.namespace.svc.cluster.local
```

Example:
```bash
psql -h my-postgres.myapp.svc.cluster.local -U postgres
```

## Security

- Runs as non-root user (UID 999)
- Container uses read-only root filesystem with tmpfs volumes for runtime needs
- Credentials managed via external Secret (not in values)

## Production Considerations

1. **Use a proper StorageClass** - Configure `persistence.storageClass` to match your storage backend (e.g., `gp3` for AWS, `pd-ssd` for GCP)

2. **Resource limits** - Adjust based on your workload

3. **Backup** - Implement regular backups using pg_dump or a Kubernetes CronJob

4. **Secret Management** - Consider using External Secrets Operator or Vault for production secrets

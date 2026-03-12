# ParadeDB Helm Chart

PostgreSQL 17 with [pgvector](https://github.com/pgvector/pgvector) and [pg_search](https://github.com/paradedb/paradedb/tree/dev/pg_search) (BM25 full-text search) pre-installed. Required by LobeHub for RAG and knowledge base search.

## TL;DR

```bash
# Create the secret first
kubectl create namespace myapp
kubectl -n myapp create secret generic paradedb-creds \
  --from-literal=username=postgres \
  --from-literal=password=your-secure-password

# Install the chart
helm install my-paradedb ./paradedb -n myapp
```

## Requirements

- Kubernetes 1.19+
- Helm 3+

## Why ParadeDB instead of plain PostgreSQL?

LobeHub requires two PostgreSQL extensions:

| Extension | Purpose |
|-----------|---------|
| `pgvector` | Vector similarity search — used for RAG (retrieval-augmented generation) |
| `pg_search` | BM25 full-text search — used for knowledge base search |

The official `postgres` image does not include either. `paradedb/paradedb` ships both out of the box.

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | ParadeDB image repository | `paradedb/paradedb` |
| `image.tag` | Image tag | `""` (uses appVersion: `latest-pg17`) |
| `postgresql.existingSecret` | Secret containing `username` and `password` keys | `paradedb-creds` |
| `postgresql.database` | Database name to create on first start | `lobechat` |
| `persistence.enabled` | Enable persistent storage | `true` |
| `persistence.storageClass` | Storage class for PVC | `""` (default) |
| `persistence.size` | PVC size | `10Gi` |
| `service.port` | PostgreSQL service port | `5432` |
| `resources.requests.cpu` | CPU request | `100m` |
| `resources.requests.memory` | Memory request | `256Mi` |
| `resources.limits.cpu` | CPU limit | `1000m` |
| `resources.limits.memory` | Memory limit | `1Gi` |

## Usage with LobeHub

This chart is designed to be used as a sub-chart of the `lobehub` chart. Enable it via:

```yaml
# lobehub/values.yaml
paradedb:
  enabled: true
  postgresql:
    existingSecret: "paradedb-creds"
    database: "lobechat"
  persistence:
    enabled: true
    size: 10Gi
```

When `paradedb.enabled=true`, the lobehub chart automatically constructs `DATABASE_URL` — no need to set `database.url` manually.

## Connecting to ParadeDB

From within the cluster:

```
<release-name>.<namespace>.svc.cluster.local:5432
```

Example one-off client pod:

```bash
kubectl run paradedb-client --rm -it --image=paradedb/paradedb:latest-pg17 --restart=Never \
  --env=PGPASSWORD=$(kubectl get secret paradedb-creds -n myapp -o jsonpath="{.data.password}" | base64 -d) \
  --command -- psql -h my-paradedb.myapp.svc.cluster.local -U postgres -d lobechat
```

## Security

- Runs as non-root user (UID/GID 999)
- Read-only root filesystem with `emptyDir` volumes for `/tmp` and `/var/run`
- Credentials managed via external Secret

## Production Considerations

1. **Storage class** — Set `persistence.storageClass` to match your cloud provider (e.g. `gp3` on AWS, `pd-ssd` on GCP).

2. **Resource limits** — ParadeDB is more memory-intensive than plain PostgreSQL due to the search indexes. Increase `resources.limits.memory` for large knowledge bases.

3. **Backups** — Implement regular backups using `pg_dump` or a Kubernetes CronJob. pgvector and pg_search indexes are stored in the data directory and will be included automatically.

4. **Secret Management** — Consider using External Secrets Operator or HashiCorp Vault for production secrets.

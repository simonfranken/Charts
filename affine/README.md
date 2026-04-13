# AFFiNE Helm Chart

Deploys [AFFiNE](https://affine.pro) to Kubernetes using the official container image.

This chart follows AFFiNE's official `docker-compose.yml` layout:

- app container (`ghcr.io/toeverything/affine`)
- migration step (`node ./scripts/self-host-predeploy.js`) as a Helm post-install/pre-upgrade hook Job
- Redis for cache/session
- PostgreSQL (via ParadeDB for pgvector support)
- persistent storage for `/root/.affine/storage` and `/root/.affine/config`

## Prerequisites

- Kubernetes 1.24+
- Helm 3.x
- Secret `paradedb-creds` containing keys `username` and `password` (when `paradedb.enabled=true`)
- Secret `redis-creds` containing key `password` (when `redis.enabled=true` and `redis.auth.enabled=true`)

## Installation

```bash
helm install affine ./affine -f my-values.yaml
```

## Minimal values

```yaml
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: affine.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: affine-tls
      hosts:
        - affine.example.com

paradedb:
  enabled: true
  postgresql:
    existingSecret: paradedb-creds
    database: affine

redis:
  enabled: true
  auth:
    enabled: true
    existingSecret: redis-creds
```

## Notes

- When `paradedb.enabled=true`, `DATABASE_URL` is auto-generated from the sub-chart service and credentials secret.
- When `redis.enabled=true`, `REDIS_SERVER_HOST` points to `<release>-redis` and password is injected from `redis.auth.existingSecret`.
- If you disable sub-charts, set external connection values under `database.*` and `externalRedis.*`.
- Migration runs after install and before upgrade, and is automatically cleaned up after success.

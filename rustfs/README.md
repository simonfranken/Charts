# RustFS Helm Chart

High-performance, 100% S3-compatible open-source object storage. Can be deployed standalone or as a sub-chart of the lobehub chart to provide managed S3 storage.

## TL;DR

```bash
# Create the secret first
kubectl create namespace myapp
kubectl -n myapp create secret generic rustfs-creds \
  --from-literal=accessKey=rustfsadmin \
  --from-literal=secretKey=your-secure-password

# Install the chart
helm install my-rustfs ./rustfs -n myapp
```

## Requirements

- Kubernetes 1.19+
- Helm 3+

## Configuration

| Parameter | Description | Default |
|---|---|---|
| `image.repository` | RustFS image repository | `rustfs/rustfs` |
| `image.tag` | Image tag | `""` (appVersion) |
| `existingSecret` | Secret with `accessKey` and `secretKey` keys | `rustfs-creds` |
| `address` | S3 API listen address | `:9000` |
| `consoleEnabled` | Enable web console on port 9001 | `true` |
| `serverDomains` | Domain for virtual-host bucket access (optional) | `""` |
| `persistence.enabled` | Enable persistent storage | `true` |
| `persistence.storageClass` | Storage class for PVC | `""` (default) |
| `persistence.size` | PVC size | `10Gi` |
| `service.apiPort` | S3 API service port | `9000` |
| `service.consolePort` | Web console service port | `9001` |
| `resources.requests.cpu` | CPU request | `100m` |
| `resources.requests.memory` | Memory request | `128Mi` |
| `resources.limits.cpu` | CPU limit | `1000m` |
| `resources.limits.memory` | Memory limit | `1Gi` |

## Credentials

This chart uses the `existingSecret` pattern — credentials are **never managed by the chart**. Create the secret before installing:

```bash
kubectl create secret generic rustfs-creds \
  --from-literal=accessKey=rustfsadmin \
  --from-literal=secretKey=your-secure-password \
  -n <namespace>
```

The secret keys are:
- `accessKey` — RustFS admin access key (`RUSTFS_ACCESS_KEY`)
- `secretKey` — RustFS admin secret key (`RUSTFS_SECRET_KEY`)

## Usage with LobeHub

This chart is designed to be used as a sub-chart of the lobehub chart. Enable it via:

```yaml
rustfs:
  enabled: true
  existingSecret: "rustfs-creds"
  bucket: "lobe"
  persistence:
    enabled: true
    size: 10Gi
```

When `rustfs.enabled=true`, the lobehub chart automatically injects all `S3_*` environment variables pointing at the RustFS instance.

## Web Console

The RustFS web console runs on port 9001 and is available as a ClusterIP service. Access it locally with:

```bash
kubectl port-forward svc/<release-name>-rustfs 9001:9001 -n <namespace>
```

Then open http://localhost:9001.

## Security

- Runs as non-root user `rustfs` (UID/GID 10001)
- Read-only root filesystem with emptyDir volume for `/tmp`
- Credentials managed via external Secret

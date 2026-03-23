# ExcaliDash Helm Chart

Deploys [ExcaliDash](https://github.com/ZimengXiong/ExcaliDash) to Kubernetes using a simple production-oriented setup:

- Single `Deployment` with 2 containers (`backend` + `frontend`)
- Optional persistent storage for backend SQLite data
- Optional ingress for public access
- Per-container resource requests/limits
- Config via ConfigMap + Secret, including existing Secret support for OIDC and other credentials

## Prerequisites

- Kubernetes 1.24+
- Helm 3.x
- A StorageClass (or an existing PVC) for persistence

## Install

```bash
helm install excalidash ./excalidash -f my-values.yaml
```

## Minimal Production Example

```yaml
# my-values.yaml
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: excalidash.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: excalidash-tls
      hosts:
        - excalidash.example.com

persistence:
  enabled: true
  size: 20Gi
  storageClass: ""

resources:
  backend:
    requests:
      cpu: 500m
      memory: 512Mi
    limits:
      cpu: 2
      memory: 2Gi
  frontend:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 500m
      memory: 512Mi

backend:
  env:
    FRONTEND_URL: https://excalidash.example.com
    TRUST_PROXY: "1"
    AUTH_MODE: local

secrets:
  existingSecret: excalidash-secrets
```

## OIDC With Existing Secret

Keep sensitive values in your own Secret and reference it via `secrets.existingSecret`.

Example secret keys:

- `JWT_SECRET`
- `CSRF_SECRET`
- `OIDC_CLIENT_SECRET`

Then set non-sensitive OIDC values in `backend.env`, for example:

```yaml
backend:
  env:
    AUTH_MODE: oidc_enforced
    OIDC_PROVIDER_NAME: Authentik
    OIDC_ISSUER_URL: https://auth.example.com/application/o/excalidash/
    OIDC_CLIENT_ID: excalidash
    OIDC_REDIRECT_URI: https://excalidash.example.com/api/auth/oidc/callback
    OIDC_SCOPES: openid profile email

secrets:
  existingSecret: excalidash-secrets
```

## Notes

- ExcaliDash backend is currently best deployed as a single replica with SQLite-backed persistence.
- This chart defaults to `replicaCount: 1`.
- Back up your PVC data regularly.

## Upgrade

```bash
helm upgrade excalidash ./excalidash -f my-values.yaml
```

## Uninstall

```bash
helm uninstall excalidash
```

PVCs are not deleted automatically on uninstall.

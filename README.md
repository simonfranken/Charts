# Simon's Helm Chart Collection

A curated collection of Helm charts used in real-world Kubernetes deployments.

## Repository Purpose

This repository contains application and infrastructure charts that are maintained with a focus on:

- pragmatic defaults for self-hosted environments,
- clear customization through `values.yaml`,
- reproducible chart releases via GitHub Pages.

## Install From Repository

```bash
helm repo add simonfranken https://simonfranken.github.io/Charts
helm repo update
helm search repo simonfranken
```

## Available Charts

| Chart | Description |
|---|---|
| `basic` | Generic starter chart for small web services |
| `excalidash` | Self-hosted dashboard and organizer for Excalidraw |
| `headscale` | Headscale control server deployment |
| `letsencrypt-issuer` | cert-manager issuer helper for Let's Encrypt |
| `lobehub` | AI chat platform with optional DB/object-store dependencies |
| `maybefinance` | Maybe Finance deployment chart |
| `mongodb` | MongoDB StatefulSet using official image |
| `n8n` | n8n workflow automation platform |
| `outline` | Outline wiki application chart |
| `paradedb` | ParadeDB PostgreSQL distribution with vector/search support |
| `pocket-id` | Pocket ID identity provider chart |
| `postgresql` | PostgreSQL database chart |
| `redis` | Redis cache chart |
| `rustfs` | RustFS S3-compatible object storage |
| `tailscale-subnet-router` | Tailscale/Headscale subnet router |

## Install A Chart

```bash
helm install my-release simonfranken/<chart-name> -f my-values.yaml
```

Example:

```bash
helm install my-redis simonfranken/redis
```

## Development

### Prerequisites

- Helm v3.12+
- Kubernetes v1.24+

### Validate Charts Locally

```bash
for chart in */Chart.yaml; do
  dir="${chart%/Chart.yaml}"
  helm dependency build "$dir"
  helm lint "$dir"
  helm template test "$dir" >/dev/null
done
```

## Release Process

- Pull requests run validation checks.
- Merges to `main` publish chart packages and update the chart index using `chart-releaser`.

## Versioning Policy

- Chart `version` follows SemVer and is bumped for any chart change.
- `appVersion` tracks upstream application versions where possible.
- Image tags in `values.yaml` are pinned by default for reproducibility.

## Security Notes

- Do not commit real credentials in chart values.
- Prefer `existingSecret` patterns or external secret managers.

Report security issues privately via `SECURITY.md`.

## License

This repository is licensed under the MIT License. See `LICENSE`.

# SearXNG Helm Chart

[SearXNG](https://searxng.org) is a privacy-respecting, hackable metasearch engine. This chart deploys SearXNG on Kubernetes, configured by default to produce JSON output for AI web search engines like [LobeHub](https://lobehub.com).

## TL;DR

```bash
helm install my-searxng ./searxng
```

## Requirements

- Kubernetes 1.19+
- Helm 3+

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | SearXNG image repository | `searxng/searxng` |
| `image.tag` | Image tag | `""` (uses `appVersion`: `latest`) |
| `service.port` | Service port | `8080` |
| `secret.secretKey` | Secret key for session encryption (auto-generated if empty) | `""` |
| `secret.existingSecret` | Name of existing secret containing `secretKey` | `""` |
| `settings.instanceName` | Instance name in UI | `"SearXNG"` |
| `settings.safeSearch` | Safe search filter (`0`: Off, `1`: Moderate, `2`: Strict) | `0` |
| `settings.autocomplete` | Autocomplete backend | `""` |
| `settings.defaultLang` | Default search language | `"auto"` |
| `settings.formats` | Enabled output formats (must include `json` for AI web browsing) | `[html, json]` |
| `settings.limiter` | Enable rate limiter | `false` |
| `settings.customSettings` | Custom YAML string to override `settings.yml` entirely | `""` |

## Usage with LobeHub

This chart can be deployed standalone or used as a sub-chart of the `lobehub` chart.

```yaml
# lobehub/values.yaml
searxng:
  enabled: true
```

When `searxng.enabled=true`, the `lobehub` chart automatically configures `SEARXNG_URL` to point to this SearXNG instance.

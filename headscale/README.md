# headscale Helm Chart

A production-ready Helm chart for deploying [Headscale](https://github.com/juanfont/headscale), an open-source implementation of the Tailscale control server, on Kubernetes.

---

## TL;DR

```sh
helm repo add simonfranken https://simonfranken.github.io/Charts/
helm repo update
helm install headscale simonfranken/headscale
```

---

## Introduction

This chart bootstraps a **Headscale** deployment on a Kubernetes cluster using best practices, including:

- Managed configuration via ConfigMap
- Optional persistent storage via PVCs
- Kubernetes-native networking with Service and Ingress
- Flexible, secure, and production-oriented defaults

---

## Prerequisites

- Kubernetes 1.20+
- Helm 3.7+
- Persistent storage provisioner (if enabling persistence)
- (Optional) An Ingress controller if enabling Ingress

---

## Installing the Chart

First, add the chart repository and update:

```sh
helm repo add simonfranken https://simonfranken.github.io/Charts/
helm repo update
```

Next, install the chart:

```sh
helm install headscale simonfranken/headscale
```

You can override configuration using the `--values my-values.yaml` flag.

---

## Minimal Configuration

At a minimum, you **should review and override** the following values in your own `values.yaml`, especially for a production setup:

```yaml
config:
  server_url: "https://headscale.example.com"
  listen_addr: "0.0.0.0:8080"
  base_domain: "tailnet.example.com" # Change this domain to match your environment

persistence:
  enabled: true

ingress:
  enabled: true
  hosts:
    - host: "headscale.example.com"
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: headscale-tls
      hosts:
        - headscale.example.com
```

**Most users should tailor:**

- `config.server_url` — must match your cluster's public Headscale endpoint.
- `config.dns.base_domain` — should be a domain you control (not the same as `server_url`).
- Storage: Set `persistence.enabled: true` for data durability.
- Ingress: Set domain and TLS if exposing to the internet.

---

## Configuration Options

The full list of values can be found in [values.yaml](./values.yaml). Some useful overrides:

| Parameter                | Description                                       | Default                         |
| ------------------------ | ------------------------------------------------- | ------------------------------- |
| `image.repository`       | Headscale container image repository              | `docker.io/headscale/headscale` |
| `image.tag`              | Headscale image tag                               | `latest`                        |
| `config.server_url`      | Publicly accessible URL for your Headscale server | `"http://127.0.0.1:8080"`       |
| `config.dns.base_domain` | Base DNS domain for MagicDNS                      | `example.com`                   |
| `persistence.enabled`    | Enable persistent storage for `/lib` and `/run`   | `true`                          |
| `ingress.enabled`        | Enable Ingress resource                           | `false`                         |
| `ingress.tls`            | Configure TLS for Ingress                         | `[]`                            |

See [values.yaml](./values.yaml) for comprehensive settings and documentation.

---

## Upgrading

To update Headscale or modify configuration:

```sh
helm upgrade headscale simonfranken/headscale --values=my-values.yaml
```

---

## Persistent Storage

By default, persistent storage is enabled for `/var/lib/headscale` and `/var/run/headscale` using PVCs.  
If persistence is disabled, ephemeral (emptyDir) volumes will be used.

---

## Ingress

An optional Ingress resource allows exposing Headscale via HTTP(s) behind a cluster Ingress controller (e.g., nginx, Traefik).  
Configure `ingress.tls` and `ingress.annotations` for Let's Encrypt, cert-manager, etc.

---

## Troubleshooting

- Ensure you configure `config.server_url` with your cluster's public reachable address.
- Persistent data requires a functioning storage class in your Kubernetes cluster.
- Exposing Headscale publicly? Always use TLS for secure connections.

---

## References

- [Headscale upstream docs](https://github.com/juanfont/headscale)
- [Tailscale DERP relay info](https://tailscale.com/blog/how-tailscale-works/)
- [Helm documentation](https://helm.sh/docs/)

---

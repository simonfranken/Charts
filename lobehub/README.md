# LobeHub Helm Chart

Deploys [LobeHub](https://lobehub.com) — an open-source AI chat platform with knowledge base, multimodal AI, and plugin support — to a Kubernetes cluster.

This chart deploys the **LobeHub application only**. All external services (PostgreSQL, Redis, S3) must be provisioned separately and connected via `values.yaml`.

## Prerequisites

- Kubernetes 1.24+
- Helm 3.x
- A PostgreSQL 14+ instance with the `pgvector` extension (e.g. [paradedb/paradedb](https://hub.docker.com/r/paradedb/paradedb), Neon, Supabase, AWS RDS)
- At least one AI provider API key (OpenAI, Anthropic, Google, etc.)
- *(Optional)* A Redis instance for session caching
- *(Optional)* An S3-compatible object store for file uploads and knowledge base (AWS S3, Cloudflare R2, MinIO, RustFS, …)

## Installation

```bash
helm install lobehub ./lobehub -f my-values.yaml
```

## Minimal configuration

```yaml
# my-values.yaml
config:
  appUrl: "https://lobehub.example.com"

database:
  url: "postgresql://postgres:password@my-postgres:5432/lobechat"

secrets:
  keyVaultsSecret: "<openssl rand -base64 32>"  # NEVER change after first deploy
  authSecret: "<openssl rand -base64 32>"
  jwksKey: "<RS256 JWKS JSON string>"           # see docs below

extraSecrets:
  OPENAI_API_KEY: "sk-..."

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: lobehub.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: lobehub-tls
      hosts:
        - lobehub.example.com
```

### Generating required secrets

```bash
# KEY_VAULTS_SECRET and AUTH_SECRET
openssl rand -base64 32

# JWKS_KEY — requires Node.js
node -e "
const { generateKeyPairSync } = require('crypto');
const { privateKey, publicKey } = generateKeyPairSync('rsa', { modulusLength: 2048 });
console.log(JSON.stringify({
  keys: [{
    ...JSON.parse(require('crypto').createPublicKey(publicKey).export({ format: 'jwk' })),
    d: privateKey.export({ format: 'jwk' }).d,
    use: 'sig', alg: 'RS256', kid: 'lobehub'
  }]
}));
"
```

## Configuration reference

### Image

| Parameter | Description | Default |
|---|---|---|
| `image.repository` | Container image | `lobehub/lobehub` |
| `image.tag` | Image tag | `latest` |
| `image.pullPolicy` | Pull policy | `IfNotPresent` |

### Application

| Parameter | Description | Default |
|---|---|---|
| `config.appUrl` | Public URL browsers use to reach LobeHub (required for OAuth callbacks) | `https://lobehub.example.com` |
| `config.internalAppUrl` | Server-to-server URL, bypasses CDN/proxy. Defaults to `appUrl` | `""` |
| `config.apiKeySelectMode` | API key selection when multiple keys are set: `random` or `turn` | `random` |
| `config.defaultAgentConfig` | Default agent settings string, e.g. `model=gpt-4;params.max_tokens=300` | `""` |
| `config.systemAgent` | System agent model config, e.g. `default=openai/gpt-4o` | `""` |
| `config.featureFlags` | Feature flag overrides, e.g. `"-welcome_suggest"` | `""` |
| `config.proxyUrl` | Outbound proxy URL, e.g. `http://127.0.0.1:7890` | `""` |
| `config.enableProxyDns` | Route DNS through proxy (`0` = local, `1` = proxy) | `"0"` |
| `config.ssrfAllowPrivateIp` | Disable SSRF protection for private IPs (`0` = deny, `1` = allow) | `"0"` |
| `config.ssrfAllowIpList` | Comma-separated private IP whitelist (when `ssrfAllowPrivateIp=0`) | `""` |
| `config.assetPrefix` | CDN URL prefix for static assets | `""` |
| `config.pluginsIndexUrl` | Custom plugin market index URL | `""` |
| `config.pluginSettings` | Plugin settings string, e.g. `search-engine:SERPAPI_API_KEY=xxxxx` | `""` |
| `config.agentsIndexUrl` | Custom assistant market index URL | `""` |

### Database

| Parameter | Description | Default |
|---|---|---|
| `database.url` | Full PostgreSQL DSN — **required** | `""` |

### Redis (optional)

| Parameter | Description | Default |
|---|---|---|
| `redis.enabled` | Enable Redis integration | `false` |
| `redis.url` | Redis connection URL, e.g. `redis://redis:6379` | `""` |
| `redis.prefix` | Key prefix for data isolation | `lobechat` |
| `redis.tls` | Enable TLS (`"true"` / `"false"`) | `"false"` |

### S3-compatible object storage (optional)

Works with AWS S3, Cloudflare R2, MinIO, RustFS, or any S3-compatible service.

| Parameter | Description | Default |
|---|---|---|
| `s3.enabled` | Enable S3 integration | `false` |
| `s3.endpoint` | S3 endpoint URL (no bucket prefix for virtual-host mode) | `""` |
| `s3.bucket` | Bucket name | `lobe` |
| `s3.region` | Bucket region (required for AWS S3) | `""` |
| `s3.enablePathStyle` | Use path-style URLs (`"1"`) or virtual-host (`"0"`). Set to `"1"` for self-hosted S3 | `"1"` |
| `s3.setAcl` | Set `public-read` ACL on upload (`"1"`) or keep private (`"0"`) | `"0"` |
| `s3.llmVisionImageUseBase64` | Convert images to base64 before sending to LLM (required when S3 is on plain HTTP) | `"1"` |
| `secrets.s3AccessKeyId` | S3 access key ID — stored in Secret | `""` |
| `secrets.s3SecretAccessKey` | S3 secret access key — stored in Secret | `""` |

### Authentication (Better Auth)

| Parameter | Description | Default |
|---|---|---|
| `auth.ssoProviders` | Comma-separated SSO providers to enable, e.g. `google,github` | `""` |
| `auth.emailVerification` | Require email verification (`"0"` / `"1"`) | `"0"` |
| `auth.disableEmailPassword` | Disable email/password login, force SSO only (`"0"` / `"1"`) | `"0"` |
| `auth.allowedEmails` | Allowed email addresses or domains, e.g. `example.com,admin@other.com` | `""` |
| `auth.internalJwtExpiration` | Internal JWT token TTL, e.g. `30s`, `1m`, `1h` | `30s` |

#### SMTP (email verification / password reset)

| Parameter | Description | Default |
|---|---|---|
| `auth.smtp.enabled` | Enable SMTP | `false` |
| `auth.smtp.host` | SMTP hostname | `""` |
| `auth.smtp.port` | SMTP port (`587` for TLS, `465` for SSL) | `"587"` |
| `auth.smtp.secure` | Use SSL (`"true"` for port 465) | `"false"` |
| `auth.smtp.user` | SMTP username / sender address | `""` |
| `auth.smtp.from` | Sender address override (defaults to `smtp.user`) | `""` |
| `secrets.smtpPassword` | SMTP password — stored in Secret | `""` |

#### Google OAuth

| Parameter | Description |
|---|---|
| `auth.google.enabled` | Enable Google OAuth |
| `auth.google.id` | Google OAuth client ID |
| `secrets.authGoogleSecret` | Google OAuth client secret — stored in Secret |

#### GitHub OAuth

| Parameter | Description |
|---|---|
| `auth.github.enabled` | Enable GitHub OAuth |
| `auth.github.id` | GitHub OAuth app client ID |
| `secrets.authGithubSecret` | GitHub OAuth client secret — stored in Secret |

#### Microsoft Entra ID (Azure AD)

| Parameter | Description | Default |
|---|---|---|
| `auth.microsoft.enabled` | Enable Microsoft OAuth | |
| `auth.microsoft.id` | Azure AD application (client) ID | |
| `auth.microsoft.tenantId` | Directory (tenant) ID | `common` |
| `auth.microsoft.authorityUrl` | Authority URL | `https://login.microsoftonline.com` |
| `secrets.authMicrosoftSecret` | Client secret — stored in Secret | |

#### AWS Cognito

| Parameter | Description |
|---|---|
| `auth.cognito.enabled` | Enable AWS Cognito OAuth |
| `auth.cognito.id` | Cognito app client ID |
| `auth.cognito.issuer` | Cognito issuer URL (`https://cognito-idp.{region}.amazonaws.com/{poolId}`) |
| `secrets.authCognitoSecret` | Cognito client secret — stored in Secret |

### Secrets

All sensitive values are stored in a Kubernetes `Secret` and mounted as environment variables.

| Parameter | Description |
|---|---|
| `secrets.keyVaultsSecret` | Encrypts sensitive data in the database. **Never change after first deploy.** Generate: `openssl rand -base64 32` |
| `secrets.authSecret` | Encrypts session tokens. Generate: `openssl rand -base64 32` |
| `secrets.jwksKey` | RS256 RSA key pair as a JWKS JSON string, used for JWT signing |

### AI provider API keys

AI provider keys are not first-class values since LobeHub supports many providers. Pass them via `extraSecrets`:

```yaml
extraSecrets:
  OPENAI_API_KEY: "sk-..."
  ANTHROPIC_API_KEY: "sk-ant-..."
  GOOGLE_API_KEY: "..."
```

For additional non-sensitive env vars use `extraEnv`:

```yaml
extraEnv:
  NODE_ENV: "production"
```

### Ingress

| Parameter | Description | Default |
|---|---|---|
| `ingress.enabled` | Create an Ingress resource | `false` |
| `ingress.className` | `ingressClassName`, e.g. `nginx` | `""` |
| `ingress.annotations` | Extra annotations map | `{}` |
| `ingress.hosts` | List of host + path rules | see `values.yaml` |
| `ingress.tls` | TLS configuration list | `[]` |

### Resources & scheduling

| Parameter | Description | Default |
|---|---|---|
| `replicaCount` | Number of pod replicas | `1` |
| `resources.requests.cpu` | CPU request | `500m` |
| `resources.requests.memory` | Memory request | `512Mi` |
| `resources.limits.cpu` | CPU limit | `2` |
| `resources.limits.memory` | Memory limit | `2Gi` |
| `securityContext.enabled` | Enable pod security context | `false` |
| `securityContext.runAsUser` | UID to run as | `1000` |
| `securityContext.runAsGroup` | GID to run as | `1000` |
| `securityContext.fsGroup` | fsGroup for volume mounts | `1000` |
| `nodeSelector` | Node selector map | `{}` |
| `tolerations` | Tolerations list | `[]` |
| `affinity` | Affinity rules | `{}` |

## Upgrade

```bash
helm upgrade lobehub ./lobehub -f my-values.yaml
```

## Uninstall

```bash
helm uninstall lobehub
```

> **Note:** This does not delete any external PostgreSQL data, Redis data, or S3 objects. Those must be cleaned up separately.

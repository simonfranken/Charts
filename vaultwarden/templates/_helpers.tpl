{{/* Generate a consistent fullname for resources */}}
{{- define "vaultwarden.fullname" -}}
{{ .Release.Name }}-{{ .Chart.Name }}
{{- end -}}

{{/* Generate a consistent name for MariaDB resources */}}
{{- define "vaultwarden.mariadb.fullname" -}}
{{ .Release.Name }}-mariadb
{{- end -}}

{{/* Standardized labels */}}
{{- define "vaultwarden.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end -}}

{{/* Standardized labels for MariaDB */}}
{{- define "vaultwarden.mariadb.labels" -}}
app.kubernetes.io/name: mariadb
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
helm.sh/chart: mariadb-{{ .Chart.Version }}
{{- end -}}

{{/* Secret name */}}
{{- define "vaultwarden.secret.name" -}}
{{ .Release.Name }}-db-secret
{{- end -}}
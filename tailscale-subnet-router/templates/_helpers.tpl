{{/*
Return the full name of the release, preferring fullnameOverride or nameOverride if set.
*/}}
{{- define "tailscale-subnet-router.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else if .Values.nameOverride }}
{{- printf "%s" .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name "tailscale-subnet-router" | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Return the name of the ServiceAccount to use
*/}}
{{- define "tailscale-subnet-router.serviceAccountName" -}}
{{- if .Values.serviceAccount.name }}
{{- .Values.serviceAccount.name }}
{{- else }}
{{- include "tailscale-subnet-router.fullname" . }}
{{- end }}
{{- end }}
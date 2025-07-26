{{- /*
Expand the name of the chart or override with .Values.nameOverride
*/ -}}
{{- define "headscale.name" -}}
{{- if .Values.nameOverride -}}
{{- .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- /*
Create a fullname for the resources, allows override with .Values.fullnameOverride
*/ -}}
{{- define "headscale.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if .Release.Name -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- /*
Standard app labels
*/ -}}
{{- define "headscale.labels" -}}
app.kubernetes.io/name: {{ include "headscale.name" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.podLabels }}
{{ toYaml .Values.podLabels | indent 0 }}
{{- end }}
{{- end -}}

{{- /*
Selector labels for Deployment and Service
*/ -}}
{{- define "headscale.selectorLabels" -}}
app.kubernetes.io/name: {{ include "headscale.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
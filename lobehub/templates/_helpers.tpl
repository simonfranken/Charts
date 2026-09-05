{{/*
Expand the name of the chart.
*/}}
{{- define "lobehub.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "lobehub.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "lobehub.selectorLabels" -}}
app.kubernetes.io/name: {{ include "lobehub.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "lobehub.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | quote }}
app.kubernetes.io/name: {{ include "lobehub.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Gateway fullname.
*/}}
{{- define "lobehub.gateway.fullname" -}}
{{- printf "%s-gateway" (include "lobehub.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Gateway selector labels — extends the app's selector labels with a
component label so its Service only ever picks up gateway pods.
*/}}
{{- define "lobehub.gateway.selectorLabels" -}}
{{- include "lobehub.selectorLabels" . }}
app.kubernetes.io/component: gateway
{{- end }}

{{/*
Gateway common labels.
*/}}
{{- define "lobehub.gateway.labels" -}}
{{- include "lobehub.labels" . }}
app.kubernetes.io/component: gateway
{{- end }}

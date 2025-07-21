{{- define "outline-wiki.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{- define "outline-wiki.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
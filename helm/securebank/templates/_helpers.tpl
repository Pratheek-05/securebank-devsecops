{{- define "securebank.name" -}}
{{- default "securebank" .Chart.Name -}}
{{- end -}}

{{- define "securebank.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "securebank.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "securebank.chart" -}}
{{ .Chart.Name }}-{{ .Chart.Version }}
{{- end -}}

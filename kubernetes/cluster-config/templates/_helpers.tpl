{{- define "cert-manager-namespace" }}
{{- index .Values "cert-manager" "namespace" }}
{{- end }}

## GLOBALS ##

{{- define "app-namespace" }}
{{- .Values.global.appNamespace }}
{{- end }}

{{- define "environment" }}
{{- .Values.global.environment }}
{{- end }}

{{- define "staging-issuer-name" }}
{{- .Values.global.issuerNames.staging }}
{{- end }}

{{- define "prod-issuer-name" }}
{{- .Values.global.issuerNames.prod }}
{{- end }}

{{- define "internal-issuer-name" }}
{{- .Values.global.issuerNames.internal }}
{{- end }}

{{- define "ca-bundle-name" }}
{{- .Values.global.caBundleName }}
{{- end }}
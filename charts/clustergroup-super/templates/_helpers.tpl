{{/*
Compute the ArgoCD namespace for the inner Application.
In singleArgoCD mode, use the global vpArgoNamespace.
Otherwise, use pattern-clusterGroupName.
*/}}
{{- define "super.argocdnamespace" -}}
{{- if .Values.clusterGroup.singleArgoCD -}}
{{- .Values.global.vpArgoNamespace -}}
{{- else -}}
{{- .Values.global.pattern }}-{{ .Values.clusterGroup.name -}}
{{- end -}}
{{- end }}

{{/*
Standard value files for the inner clustergroup Application (multisource, with $patternref/ prefix).
Mirrors clustergroup.app.globalvalues.prefixedvaluefiles from the clustergroup chart,
but uses literal $.Values.global.* values (already resolved by ACM on the spoke).
*/}}
{{- define "super.globalvalues.prefixedvaluefiles" -}}
- "$patternref/values-global.yaml"
- "$patternref/values-{{ $.Values.clusterGroup.name }}.yaml"
{{- if $.Values.global.clusterPlatform }}
- "$patternref/values-{{ $.Values.global.clusterPlatform }}.yaml"
  {{- if $.Values.global.clusterVersion }}
- "$patternref/values-{{ $.Values.global.clusterPlatform }}-{{ $.Values.global.clusterVersion }}.yaml"
  {{- end }}
- "$patternref/values-{{ $.Values.global.clusterPlatform }}-{{ $.Values.clusterGroup.name }}.yaml"
{{- end }}
{{- if $.Values.global.clusterVersion }}
- "$patternref/values-{{ $.Values.global.clusterVersion }}-{{ $.Values.clusterGroup.name }}.yaml"
{{- end }}
{{- if $.Values.global.localClusterName }}
- "$patternref/values-{{ $.Values.global.localClusterName }}.yaml"
{{- end }}
{{- if $.Values.global.extraValueFiles }}
{{- range $.Values.global.extraValueFiles }}
- "$patternref/{{ . }}"
{{- end }}
{{- end }}
{{- end }}

{{/*
Resolve sharedValueFiles via tpl and add $patternref/ prefix.
This is the key capability: tpl runs on the spoke where values are correct.
*/}}
{{- define "super.sharedvaluefiles" -}}
{{- range $valueFile := $.Values.clusterGroup.sharedValueFiles }}
{{- $resolvedFile := tpl $valueFile $ }}
{{- if hasPrefix "$patternref/" $resolvedFile }}
- {{ $resolvedFile | quote }}
{{- else }}
- {{ printf "$patternref%s" $resolvedFile | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Helm parameters to pass through to the inner clustergroup Application.
These are all literal values (already resolved by ACM).
*/}}
{{- define "super.globalvalues.helmparameters" -}}
- name: global.repoURL
  value: {{ $.Values.global.repoURL }}
- name: global.originURL
  value: {{ $.Values.global.originURL }}
- name: global.targetRevision
  value: {{ $.Values.global.targetRevision }}
- name: global.namespace
  value: $ARGOCD_APP_NAMESPACE
- name: global.pattern
  value: {{ $.Values.global.pattern }}
- name: global.hubClusterDomain
  value: {{ $.Values.global.hubClusterDomain }}
- name: global.localClusterDomain
  value: {{ coalesce $.Values.global.localClusterDomain $.Values.global.hubClusterDomain }}
- name: global.clusterDomain
  value: {{ $.Values.global.clusterDomain }}
- name: global.clusterVersion
  value: "{{ $.Values.global.clusterVersion }}"
- name: global.clusterPlatform
  value: "{{ $.Values.global.clusterPlatform }}"
- name: global.localClusterName
  value: {{ $.Values.global.localClusterName }}
- name: global.multiSourceSupport
  value: {{ $.Values.global.multiSourceSupport | quote }}
- name: global.multiSourceRepoUrl
  value: {{ $.Values.global.multiSourceRepoUrl }}
- name: global.multiSourceTargetRevision
  value: {{ $.Values.global.multiSourceTargetRevision }}
- name: global.privateRepo
  value: {{ $.Values.global.privateRepo | quote }}
- name: global.experimentalCapabilities
  value: {{ $.Values.global.experimentalCapabilities | default "" }}
- name: global.deletePattern
  value: {{ $.Values.global.deletePattern }}
- name: global.gitOpsSubNamespace
  value: {{ $.Values.global.gitOpsSubNamespace | default "" }}
- name: global.vpArgoNamespace
  value: {{ $.Values.global.vpArgoNamespace }}
{{- end }}

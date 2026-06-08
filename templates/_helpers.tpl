{{/*
Default always defined valueFiles to be included when pushing the cluster wide argo application via acm
*/}}
{{- define "acm.app.policies.valuefiles" -}}
{{- if $.Values.global.vpNewFolderDir }}
- "/values-global.yaml"
- "/variants/{{ $.Values.clusterGroup.name }}/values-{{ .name }}.yaml"
- '/variants/{{ $.Values.clusterGroup.name }}/values-{{ `{{ (lookup "config.openshift.io/v1" "Infrastructure" "" "cluster").spec.platformSpec.type }}` }}.yaml'
- '/variants/{{ $.Values.clusterGroup.name }}/values-{{ `{{ (lookup "config.openshift.io/v1" "Infrastructure" "" "cluster").spec.platformSpec.type }}` }}-{{ `{{ printf "%d.%d" ((semver (index (lookup "config.openshift.io/v1" "ClusterVersion" "" "version").status.history 0).version).Major) ((semver (index (lookup "config.openshift.io/v1" "ClusterVersion" "" "version").status.history 0).version).Minor) }}` }}.yaml'
- '/variants/{{ $.Values.clusterGroup.name }}/values-{{ `{{ (lookup "config.openshift.io/v1" "Infrastructure" "" "cluster").spec.platformSpec.type }}` }}-{{ .name }}.yaml'
# We cannot use $.Values.global.clusterVersion because that gets resolved to the
# hub's cluster version, whereas we want to include the spoke cluster version
- '/variants/{{ $.Values.clusterGroup.name }}/values-{{ `{{ printf "%d.%d" ((semver (index (lookup "config.openshift.io/v1" "ClusterVersion" "" "version").status.history 0).version).Major) ((semver (index (lookup "config.openshift.io/v1" "ClusterVersion" "" "version").status.history 0).version).Minor) }}` }}-{{ .name }}.yaml'
- '/variants/{{ $.Values.clusterGroup.name }}/values-{{ `{{ (split "." (lookup "config.openshift.io/v1" "Ingress" "" "cluster").spec.domain)._1 }}` }}.yaml'
{{- else }}
- "/values-global.yaml"
- "/values-{{ .name }}.yaml"
- '/values-{{ `{{ (lookup "config.openshift.io/v1" "Infrastructure" "" "cluster").spec.platformSpec.type }}` }}.yaml'
- '/values-{{ `{{ (lookup "config.openshift.io/v1" "Infrastructure" "" "cluster").spec.platformSpec.type }}` }}-{{ `{{ printf "%d.%d" ((semver (index (lookup "config.openshift.io/v1" "ClusterVersion" "" "version").status.history 0).version).Major) ((semver (index (lookup "config.openshift.io/v1" "ClusterVersion" "" "version").status.history 0).version).Minor) }}` }}.yaml'
- '/values-{{ `{{ (lookup "config.openshift.io/v1" "Infrastructure" "" "cluster").spec.platformSpec.type }}` }}-{{ .name }}.yaml'
# We cannot use $.Values.global.clusterVersion because that gets resolved to the
# hub's cluster version, whereas we want to include the spoke cluster version
- '/values-{{ `{{ printf "%d.%d" ((semver (index (lookup "config.openshift.io/v1" "ClusterVersion" "" "version").status.history 0).version).Major) ((semver (index (lookup "config.openshift.io/v1" "ClusterVersion" "" "version").status.history 0).version).Minor) }}` }}-{{ .name }}.yaml'
- '/values-{{ `{{ (split "." (lookup "config.openshift.io/v1" "Ingress" "" "cluster").spec.domain)._1 }}` }}.yaml'
{{- end }} {{/* if $.Values.global.vpNewFolderDir */}}
{{- end }} {{- /*acm.app.policies.valuefiles */}}

{{- define "acm.app.policies.multisourcevaluefiles" -}}
{{- if $.Values.global.vpNewFolderDir }}
- "$patternref/values-global.yaml"
- "$patternref/variants/{{ $.Values.clusterGroup.name }}/values-{{ .name }}.yaml"
- '$patternref/variants/{{ $.Values.clusterGroup.name }}/values-{{ `{{ (lookup "config.openshift.io/v1" "Infrastructure" "" "cluster").spec.platformSpec.type }}` }}.yaml'
- '$patternref/variants/{{ $.Values.clusterGroup.name }}/values-{{ `{{ (lookup "config.openshift.io/v1" "Infrastructure" "" "cluster").spec.platformSpec.type }}` }}-{{ `{{ printf "%d.%d" ((semver (index (lookup "config.openshift.io/v1" "ClusterVersion" "" "version").status.history 0).version).Major) ((semver (index (lookup "config.openshift.io/v1" "ClusterVersion" "" "version").status.history 0).version).Minor) }}` }}.yaml'
- '$patternref/variants/{{ $.Values.clusterGroup.name }}/values-{{ `{{ (lookup "config.openshift.io/v1" "Infrastructure" "" "cluster").spec.platformSpec.type }}` }}-{{ .name }}.yaml'
# We cannot use $.Values.global.clusterVersion because that gets resolved to the
# hub's cluster version, whereas we want to include the spoke cluster version
- '$patternref/variants/{{ $.Values.clusterGroup.name }}/values-{{ `{{ printf "%d.%d" ((semver (index (lookup "config.openshift.io/v1" "ClusterVersion" "" "version").status.history 0).version).Major) ((semver (index (lookup "config.openshift.io/v1" "ClusterVersion" "" "version").status.history 0).version).Minor) }}` }}-{{ .name }}.yaml'
- '$patternref/variants/{{ $.Values.clusterGroup.name }}/values-{{ `{{ (split "." (lookup "config.openshift.io/v1" "Ingress" "" "cluster").spec.domain)._1 }}` }}.yaml'
{{- else }}
- "$patternref/values-global.yaml"
- "$patternref/values-{{ .name }}.yaml"
- '$patternref/values-{{ `{{ (lookup "config.openshift.io/v1" "Infrastructure" "" "cluster").spec.platformSpec.type }}` }}.yaml'
- '$patternref/values-{{ `{{ (lookup "config.openshift.io/v1" "Infrastructure" "" "cluster").spec.platformSpec.type }}` }}-{{ `{{ printf "%d.%d" ((semver (index (lookup "config.openshift.io/v1" "ClusterVersion" "" "version").status.history 0).version).Major) ((semver (index (lookup "config.openshift.io/v1" "ClusterVersion" "" "version").status.history 0).version).Minor) }}` }}.yaml'
- '$patternref/values-{{ `{{ (lookup "config.openshift.io/v1" "Infrastructure" "" "cluster").spec.platformSpec.type }}` }}-{{ .name }}.yaml'
# We cannot use $.Values.global.clusterVersion because that gets resolved to the
# hub's cluster version, whereas we want to include the spoke cluster version
- '$patternref/values-{{ `{{ printf "%d.%d" ((semver (index (lookup "config.openshift.io/v1" "ClusterVersion" "" "version").status.history 0).version).Major) ((semver (index (lookup "config.openshift.io/v1" "ClusterVersion" "" "version").status.history 0).version).Minor) }}` }}-{{ .name }}.yaml'
- '$patternref/values-{{ `{{ (split "." (lookup "config.openshift.io/v1" "Ingress" "" "cluster").spec.domain)._1 }}` }}.yaml'
{{- end }} {{/* if $.Values.global.vpNewFolderDir */}}
{{- end }} {{- /*acm.app.policies.multisourcevaluefiles */}}

{{- define "acm.app.policies.hubmultisourcevaluefiles" -}}
- "$patternref/values-global.yaml"
- "$patternref/values-{{ $group.name }}.yaml"
- '$patternref/values-{{ `{{ (lookup "config.openshift.io/v1" "Infrastructure" "" "cluster").spec.platformSpec.type }}` }}.yaml'
- '$patternref/values-{{ `{{ (lookup "config.openshift.io/v1" "Infrastructure" "" "cluster").spec.platformSpec.type }}` }}-{{ `{{ printf "%d.%d" ((semver (index (lookup "config.openshift.io/v1" "ClusterVersion" "" "version").status.history 0).version).Major) ((semver (index (lookup "config.openshift.io/v1" "ClusterVersion" "" "version").status.history 0).version).Minor) }}` }}.yaml'
- '$patternref/values-{{ `{{ (lookup "config.openshift.io/v1" "Infrastructure" "" "cluster").spec.platformSpec.type }}` }}-{{ .name }}.yaml'
# We cannot use $.Values.global.clusterVersion because that gets resolved to the
# hub's cluster version, whereas we want to include the spoke cluster version
- '$patternref/values-{{ `{{ printf "%d.%d" ((semver (index (lookup "config.openshift.io/v1" "ClusterVersion" "" "version").status.history 0).version).Major) ((semver (index (lookup "config.openshift.io/v1" "ClusterVersion" "" "version").status.history 0).version).Minor) }}` }}-{{ .name }}.yaml'
- '$patternref/values-{{ `{{ (split "." (lookup "config.openshift.io/v1" "Ingress" "" "cluster").spec.domain)._1 }}` }}.yaml'
{{- end }} {{- /*acm.app.policies.multisourcevaluefiles */}}

{{- define "acm.app.policies.helmparameters" -}}
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
  value: '{{ `{{ (lookup "config.openshift.io/v1" "Ingress" "" "cluster").spec.domain }}` }}'
- name: global.clusterDomain
  value: '{{ `{{ (lookup "config.openshift.io/v1" "Ingress" "" "cluster").spec.domain | replace "apps." "" }}` }}'
- name: global.clusterVersion
  value: '{{ `{{ printf "%d.%d" ((semver (index (lookup "config.openshift.io/v1" "ClusterVersion" "" "version").status.history 0).version).Major) ((semver (index (lookup "config.openshift.io/v1" "ClusterVersion" "" "version").status.history 0).version).Minor) }}` }}'
- name: global.localClusterName
  value: '{{ `{{ (split "." (lookup "config.openshift.io/v1" "Ingress" "" "cluster").spec.domain)._1 }}` }}'
- name: global.clusterPlatform
  value: '{{ `{{ (lookup "config.openshift.io/v1" "Infrastructure" "" "cluster").spec.platformSpec.type }}` }}'
- name: global.multiSourceSupport
  value: {{ $.Values.global.multiSourceSupport | quote }}
- name: global.multiSourceRepoUrl
  value: {{ $.Values.global.multiSourceRepoUrl }}
- name: global.multiSourceTargetRevision
  value: {{ $.Values.global.multiSourceTargetRevision }}
- name: global.privateRepo
  value: {{ $.Values.global.privateRepo | quote }}
- name: global.experimentalCapabilities
  value: {{ $.Values.global.experimentalCapabilities }}
{{/*
if this chart gets DeleteSpokeChildApps, it will set deletePattern to DeleteChildApps to remove the child apps from spokes
*/}}
- name: global.deletePattern
  {{- if eq $.Values.global.deletePattern "DeleteSpokeChildApps" }}
  value: DeleteChildApps
  {{- else }}
  value: {{ $.Values.global.deletePattern }}
  {{- end }}
- name: global.gitOpsSubNamespace
  value: {{ $.Values.global.gitOpsSubNamespace }}
- name: global.vpArgoNamespace
  value: {{ $.Values.global.vpArgoNamespace }}
- name: global.vpNewFolderDir
  value: {{ $.Values.global.vpNewFolderDir | quote | default "false" }}  
{{- end }} {{- /*acm.app.policies.helmparameters */}}

{{- define "acm.app.clusterSelector" -}}
{{- $cs := .clusterSelector -}}
{{- $g  := default (dict) .group -}}
{{- $rawLabels := get $g "acmlabels" -}}
{{- $isSlice := kindIs "slice" $rawLabels -}}
{{- $isMap   := kindIs "map"   $rawLabels -}}
{{- $hasAny  := and $rawLabels (gt (len $rawLabels) 0) -}}
{{- if $cs -}}
predicates:
  - requiredClusterSelector:
      labelSelector: {{ $cs | toPrettyJson | nindent 8 }}
{{- else if not $hasAny -}}
predicates:
  - requiredClusterSelector:
      labelSelector:
        matchExpressions:
          - key: local-cluster
            operator: NotIn
            values:
              - 'true'
        matchLabels:
          clusterGroup: {{ $g.name }}
{{- else if $isSlice -}}
predicates:
  - requiredClusterSelector:
      labelSelector:
        matchExpressions:
          - key: local-cluster
            operator: NotIn
            values:
              - 'true'
        matchLabels:
{{- range $rawLabels }}
          {{ .name }}: {{ .value }}
{{- end }}
{{- else if $isMap -}}
predicates:
  - requiredClusterSelector:
      labelSelector:
        matchExpressions:
          - key: local-cluster
            operator: NotIn
            values:
              - 'true'
        matchLabels:
{{- range $k, $v := $rawLabels }}
          {{ $k }}: {{ $v }}
{{- end }}
{{- else -}} {{- /* Fallback: unknown acmlabels shape then default to group */}}
predicates:
  - requiredClusterSelector:
      labelSelector:
        matchExpressions:
          - key: local-cluster
            operator: NotIn
            values:
              - 'true'
        matchLabels:
          clusterGroup: {{ $g.name }}
{{- end -}}
{{- end -}} {{- /*acm.app.clusterSelector */}}

{{/* Please make sure that these healthchecks are the same in the operator code */}}
{{- define "acm.default.healthchecks" -}}
- group: operators.coreos.com
  kind: Subscription
  check: |
    local health_status = {}
    if obj.status ~= nil then
      if obj.status.conditions ~= nil then
        local numDegraded = 0
        local numPending = 0
        local msg = ""

        -- Check if this is a manual approval scenario where InstallPlanPending is expected
        -- and the operator is already installed (upgrade pending, not initial install)
        local isManualApprovalPending = false
        if obj.spec ~= nil and obj.spec.installPlanApproval == "Manual" then
          for _, condition in pairs(obj.status.conditions) do
            if condition.type == "InstallPlanPending" and condition.status == "True" and condition.reason == "RequiresApproval" then
              -- Only treat as expected healthy state if the operator is already installed
              -- (installedCSV is present), meaning this is an upgrade pending approval
              if obj.status.installedCSV ~= nil then
                isManualApprovalPending = true
              end
              break
            end
          end
        end

        for i, condition in pairs(obj.status.conditions) do
          -- Skip InstallPlanPending condition when manual approval is pending (expected behavior)
          if isManualApprovalPending and condition.type == "InstallPlanPending" then
            -- Do not include in message or count as pending
          else
            msg = msg .. i .. ": " .. condition.type .. " | " .. condition.status .. "\n"
            if condition.type == "InstallPlanPending" and condition.status == "True" then
              numPending = numPending + 1
            elseif (condition.type == "InstallPlanMissing" and condition.reason ~= "ReferencedInstallPlanNotFound") then
              numDegraded = numDegraded + 1
            elseif (condition.type == "CatalogSourcesUnhealthy" or condition.type == "InstallPlanFailed" or condition.type == "ResolutionFailed") and condition.status == "True" then
              numDegraded = numDegraded + 1
            end
          end
        end

        -- Available states: undef/nil, UpgradeAvailable, UpgradePending, UpgradeFailed, AtLatestKnown
        -- Source: https://github.com/openshift/operator-framework-olm/blob/5e2c73b7663d0122c9dc3e59ea39e515a31e2719/staging/api/pkg/operators/v1alpha1/subscription_types.go#L17-L23
        if obj.status.state == nil  then
          numPending = numPending + 1
          msg = msg .. ".status.state not yet known\n"
        elseif obj.status.state == "" or obj.status.state == "UpgradeAvailable" then
          numPending = numPending + 1
          msg = msg .. ".status.state is '" .. obj.status.state .. "'\n"
        elseif obj.status.state == "UpgradePending" then
          -- UpgradePending with manual approval is expected behavior, treat as healthy
          if isManualApprovalPending then
            msg = msg .. ".status.state is 'AtLatestKnown'\n"
          else
            numPending = numPending + 1
            msg = msg .. ".status.state is '" .. obj.status.state .. "'\n"
          end
        elseif obj.status.state == "UpgradeFailed" then
          numDegraded = numDegraded + 1
          msg = msg .. ".status.state is '" .. obj.status.state .. "'\n"
        else
          -- Last possiblity of .status.state: AtLatestKnown
          msg =  msg .. ".status.state is '" .. obj.status.state .. "'\n"
        end

        if numDegraded == 0 and numPending == 0 then
          health_status.status = "Healthy"
          health_status.message = msg
          return health_status
        elseif numPending > 0 and numDegraded == 0 then
          health_status.status = "Progressing"
          health_status.message = msg
          return health_status
        else
          health_status.status = "Degraded"
          health_status.message = msg
          return health_status
        end
      end
    end
    health_status.status = "Progressing"
    health_status.message = "An install plan for a subscription is pending installation"
    return health_status
- kind: PersistentVolumeClaim
  check: |
    hs = {}
    if obj.status ~= nil then
      if obj.status.phase ~= nil then
        if obj.status.phase == "Pending" then
          hs.status = "Healthy"
          hs.message = obj.status.phase
          return hs
        elseif obj.status.phase == "Bound" then
          hs.status = "Healthy"
          hs.message = obj.status.phase
          return hs
        end
      end
    end
    hs.status = "Progressing"
    hs.message = "Waiting for PVC"
    return hs
{{- end }} {{- /*acm.default.healthchecks */}}

{{/*
Determines if the current cluster is a hub cluster.
First checks if clusterGroup.isHubCluster is explicitly set and uses that value.
If not set, falls back to comparing global.localClusterDomain and global.hubClusterDomain.
If domains are equal or localClusterDomain is not set (defaults to hubClusterDomain), this is a hub cluster.
Usage: {{ include "acm.ishubcluster" . }}
Returns: "true" or "false" as a string
*/}}
{{- define "acm.ishubcluster" -}}
{{- if and (hasKey .Values.clusterGroup "isHubCluster") (not (kindIs "invalid" .Values.clusterGroup.isHubCluster)) -}}
{{- .Values.clusterGroup.isHubCluster | toString -}}
{{- else if $.Values.global.hubClusterDomain -}}
{{- $localDomain := coalesce $.Values.global.localClusterDomain $.Values.global.hubClusterDomain -}}
{{- if eq $localDomain $.Values.global.hubClusterDomain -}}
true
{{- else -}}
false
{{- end -}}
{{- else -}}
false
{{- end -}}
{{- end }}

{{/*
Default ArgoCD spec for spoke clusters. Rendered as YAML, parsed by fromYaml,
and optionally merged with acm.customArgoYaml via mustMergeOverwrite.
*/}}
{{- define "acm.default.argocd.spec" -}}
applicationSet:
  resources:
    limits:
      cpu: "2"
      memory: 1Gi
    requests:
      cpu: 250m
      memory: 512Mi
  webhookServer:
    ingress:
      enabled: false
    route:
      enabled: false
controller:
  processors: {}
  resources:
    limits:
      cpu: "2"
      memory: 2Gi
    requests:
      cpu: 250m
      memory: 1Gi
  sharding: {}
grafana:
  enabled: false
  ingress:
    enabled: false
  resources:
    limits:
      cpu: 500m
      memory: 256Mi
    requests:
      cpu: 250m
      memory: 128Mi
  route:
    enabled: false
ha:
  enabled: false
  resources:
    limits:
      cpu: 500m
      memory: 256Mi
    requests:
      cpu: 250m
      memory: 128Mi
initialSSHKnownHosts: {}
monitoring:
  enabled: false
notifications:
  enabled: false
prometheus:
  enabled: false
  ingress:
    enabled: false
  route:
    enabled: false
rbac:
  defaultPolicy: role:readonly
  policy: |-
    g, system:cluster-admins, role:admin
    g, cluster-admins, role:admin
    g, admin, role:admin
  scopes: '[groups,email]'
redis:
  resources:
    limits:
      cpu: 500m
      memory: 256Mi
    requests:
      cpu: 250m
      memory: 128Mi
repo:
  initContainers:
  - command:
    - bash
    - -c
    - cat /var/run/kube-root-ca/ca.crt /var/run/trusted-ca/ca-bundle.crt /var/run/trusted-hub/hub-kube-root-ca.crt > /tmp/ca-bundles/ca-bundle.crt
      || true
    image: registry.redhat.io/ubi9/ubi-minimal:latest
    name: fetch-ca
    resources: {}
    volumeMounts:
    - mountPath: /var/run/kube-root-ca
      name: kube-root-ca
    - mountPath: /var/run/trusted-ca
      name: trusted-ca-bundle
    - mountPath: /var/run/trusted-hub
      name: trusted-hub-bundle
    - mountPath: /tmp/ca-bundles
      name: ca-bundles
  resources:
    limits:
      cpu: "1"
      memory: 1Gi
    requests:
      cpu: 250m
      memory: 256Mi
  volumeMounts:
  - mountPath: /etc/pki/tls/certs
    name: ca-bundles
  volumes:
  - configMap:
      name: kube-root-ca.crt
    name: kube-root-ca
  - configMap:
      name: trusted-ca-bundle
    name: trusted-ca-bundle
  - configMap:
      name: trusted-hub-bundle
    name: trusted-hub-bundle
  - emptyDir: {}
    name: ca-bundles
resourceExclusions: |-
  - apiGroups:
    - tekton.dev
    clusters:
    - '*'
    kinds:
    - TaskRun
    - PipelineRun
resourceHealthChecks:
{{- include "acm.default.healthchecks" . | nindent 2 }}
{{- range $.Values.acm.extraResourceHealthChecks }}
  - group: {{ .group }}
    kind: {{ .kind }}
    check: |
{{ .check | nindent 6 }}
{{- end }}
server:
  initContainers:
  - command:
    - bash
    - -c
    - sleep 5
    image: registry.redhat.io/ubi9/ubi-minimal:latest
    name: wait-for-appproject
    resources: {}
  autoscale:
    enabled: false
  grpc:
    ingress:
      enabled: false
  ingress:
    enabled: false
  resources:
    limits:
      cpu: 500m
      memory: 256Mi
    requests:
      cpu: 125m
      memory: 128Mi
  route:
    enabled: true
    {{- if and ($.Values.global.argocdServer) ($.Values.global.argocdServer.route) ($.Values.global.argocdServer.route.tls) }}
    tls:
      insecureEdgeTerminationPolicy: {{ default "Redirect" $.Values.global.argocdServer.route.tls.insecureEdgeTerminationPolicy }}
      termination: {{ default "reencrypt" $.Values.global.argocdServer.route.tls.termination }}
    {{- end }}
  service:
    type: ""
sso:
  dex:
    openShiftOAuth: true
    resources:
      limits:
        cpu: 500m
        memory: 256Mi
      requests:
        cpu: 250m
        memory: 128Mi
  provider: dex
tls:
  ca: {}
{{- end }}

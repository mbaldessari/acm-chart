#!/bin/bash
set -euo pipefail
#
# ArgoCD CMP generate script — two-pass Helm rendering with sharedValueFiles
#
# Pass 1: Render a throwaway chart with the same values/params to extract
#          clusterGroup.sharedValueFiles entries and resolve their Helm template
#          expressions (e.g. '{{ $.Values.global.clusterPlatform }}' -> 'AWS')
# Pass 2: Render the real clustergroup chart with the resolved override files
#          appended as extra -f arguments so they affect the chart's own rendering.
#
# Handles both modes:
#   Single-source:  chart lives in the pattern repo (path: common/clustergroup)
#   Multi-source:   chart is pulled from a Helm/git repo (PARAM_CHART_* env vars)
#
# Environment variables (set via Application plugin.env):
#   PARAM_VALUE_FILES        — newline-separated list of value file paths
#   PARAM_HELM_SET           — newline-separated name=value helm --set args
#   PARAM_INLINE_VALUES      — inline YAML values string
#   PARAM_CHART_REPO_URL     — (multi-source) Helm repo URL for the chart
#   PARAM_CHART_NAME         — (multi-source) chart name
#   PARAM_CHART_VERSION      — (multi-source) chart version
#   PARAM_CHART_GIT_URL      — (multi-source) git repo URL for the chart
#   PARAM_CHART_GIT_REVISION — (multi-source) git revision for the chart
#

# ArgoCD CMP prefixes plugin env vars with ARGOCD_ENV_.
# Map them back to the unprefixed names our script expects.
for _v in $(compgen -v ARGOCD_ENV_); do
  declare "${_v#ARGOCD_ENV_}=${!_v}"
done

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
echo "CMP: REPO_ROOT=${REPO_ROOT} pwd=$(pwd)" >&2
echo "CMP: PARAM_CHART_REPO_URL=${PARAM_CHART_REPO_URL:-unset}" >&2
echo "CMP: PARAM_VALUE_FILES='${PARAM_VALUE_FILES:-unset}'" >&2

# ── Determine chart location ──

CHART_DIR=""
if [[ -n "${PARAM_CHART_REPO_URL:-}" ]]; then
  # Multi-source: pull chart from Helm repo
  CHART_DIR=$(mktemp -d)
  CHART_NAME="${PARAM_CHART_NAME:?PARAM_CHART_NAME required}"
  CHART_VERSION="${PARAM_CHART_VERSION:?PARAM_CHART_VERSION required}"
  if [[ "$PARAM_CHART_REPO_URL" == oci://* ]]; then
    helm pull "${PARAM_CHART_REPO_URL}/${CHART_NAME}" \
      --version "$CHART_VERSION" --untar -d "$CHART_DIR" >&2
  else
    helm repo add _vp "$PARAM_CHART_REPO_URL" >&2 || true
    helm repo update _vp >&2 || true
    helm pull "_vp/${CHART_NAME}" \
      --version "$CHART_VERSION" --untar -d "$CHART_DIR" >&2
  fi
  CHART_PATH="${CHART_DIR}/${CHART_NAME}"

elif [[ -n "${PARAM_CHART_GIT_URL:-}" ]]; then
  # Multi-source: clone chart from git repo
  CHART_DIR=$(mktemp -d)
  CHART_REV="${PARAM_CHART_GIT_REVISION:-main}"
  git init "$CHART_DIR/repo" >&2 2>/dev/null
  git -C "$CHART_DIR/repo" remote add origin "$PARAM_CHART_GIT_URL" >&2 2>/dev/null
  git -C "$CHART_DIR/repo" fetch --depth 1 origin "$CHART_REV" >&2 2>/dev/null
  git -C "$CHART_DIR/repo" checkout FETCH_HEAD >&2 2>/dev/null
  CHART_PATH="$CHART_DIR/repo"

else
  # Single-source: chart is in the pattern repo at the Application source path
  CHART_PATH="$(pwd)"
fi

# ── Build base helm arguments from plugin env ──

VF_ARGS=()
if [[ -n "${PARAM_VALUE_FILES:-}" ]]; then
  while IFS= read -r vf; do
    [[ -z "$vf" ]] && continue
    vf="${vf#/}"
    [[ -f "${REPO_ROOT}/${vf}" ]] && VF_ARGS+=("-f" "${REPO_ROOT}/${vf}")
  done <<< "$PARAM_VALUE_FILES"
fi

SET_ARGS=()
# ArgoCD provides these as env vars to the CMP; map them to helm params
SET_ARGS+=("--set" "global.namespace=${ARGOCD_APP_NAMESPACE:-default}")
if [[ -n "${PARAM_HELM_SET:-}" ]]; then
  while IFS= read -r param; do
    [[ -z "$param" ]] && continue
    SET_ARGS+=("--set-string" "$param")
  done <<< "$PARAM_HELM_SET"
fi

INLINE_FILE=""
if [[ -n "${PARAM_INLINE_VALUES:-}" ]]; then
  INLINE_FILE=$(mktemp)
  printf '%s' "$PARAM_INLINE_VALUES" > "$INLINE_FILE"
  VF_ARGS+=("-f" "$INLINE_FILE")
fi

EXTRACT_DIR=$(mktemp -d)
cleanup() { rm -rf "$EXTRACT_DIR" ${CHART_DIR:+"$CHART_DIR"} ${INLINE_FILE:+"$INLINE_FILE"}; }
trap cleanup EXIT

# ── Pass 1: Resolve sharedValueFiles ──
#
# We create a minimal throwaway chart whose only template uses tpl to resolve
# each sharedValueFiles entry.  We feed it the same values and --set params
# that the real chart will receive so that any {{ $.Values.xxx }} expression
# resolves correctly.

LB=$'\x7b\x7b'
RB=$'\x7d\x7d'

mkdir -p "$EXTRACT_DIR/templates"

cat > "$EXTRACT_DIR/Chart.yaml" <<EOF
apiVersion: v2
name: extractor
version: 0.0.1
EOF

cat > "$EXTRACT_DIR/templates/resolve.yaml" <<RESOLVE_TMPL
apiVersion: v1
kind: ConfigMap
metadata:
  name: extractor
data:
  resolved: |
${LB}- if and .Values.clusterGroup .Values.clusterGroup.sharedValueFiles -${RB}
${LB}- range .Values.clusterGroup.sharedValueFiles ${RB}
    RESOLVED_SVF=${LB} tpl . \$ ${RB}
${LB}- end ${RB}
${LB}- end ${RB}
RESOLVE_TMPL

SHARED_VF_ARGS=()
echo "CMP: VF_ARGS=${VF_ARGS[*]:-none}" >&2
echo "CMP: Pass 1 extractor template:" >&2
cat "$EXTRACT_DIR/templates/resolve.yaml" >&2
PASS1_STDERR=$(mktemp)
if RESOLVED=$(helm template extractor "$EXTRACT_DIR" \
    ${VF_ARGS[@]+"${VF_ARGS[@]}"} \
    ${SET_ARGS[@]+"${SET_ARGS[@]}"} 2>"$PASS1_STDERR"); then
  echo "CMP: Pass 1 stdout: ${RESOLVED}" >&2
  echo "CMP: Pass 1 stderr: $(cat "$PASS1_STDERR")" >&2
else
  echo "CMP: Pass 1 FAILED (exit $?)" >&2
  echo "CMP: Pass 1 stderr: $(cat "$PASS1_STDERR")" >&2
fi
rm -f "$PASS1_STDERR"
if [[ -n "${RESOLVED:-}" ]]; then
  while IFS= read -r line; do
    line="${line#"${line%%[![:space:]]*}"}"
    [[ "$line" == RESOLVED_SVF=* ]] || continue
    rpath="${line#RESOLVED_SVF=}"
    rpath="${rpath#/}"
    if [[ -n "$rpath" && -f "${REPO_ROOT}/${rpath}" ]]; then
      SHARED_VF_ARGS+=("-f" "${REPO_ROOT}/${rpath}")
      echo "CMP: resolved sharedValueFile -> ${rpath}" >&2
    fi
  done <<< "$RESOLVED"
fi

# ── Pass 2: Full render with resolved sharedValueFiles ──

helm dependency build "$CHART_PATH" >&2 2>/dev/null || true

exec helm template "${ARGOCD_APP_NAME:-release}" "$CHART_PATH" \
  --namespace "${ARGOCD_APP_NAMESPACE:-default}" \
  --include-crds \
  ${VF_ARGS[@]+"${VF_ARGS[@]}"} \
  ${SET_ARGS[@]+"${SET_ARGS[@]}"} \
  ${SHARED_VF_ARGS[@]+"${SHARED_VF_ARGS[@]}"}

#!/usr/bin/env bash
#===============================================================================
# Fichier      : diagnostic.sh
# Description  : Diagnotique tous les events pour la résolution de problèmes
# Dépendances  : core.sh, global.env
#===============================================================================

# definition de la racine de la stack trace
Function_PATH="/"
# definition de la racine du projet
if [ -z ${root_path} ]
   then 
    export root_path="$(dirname $(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd))"
fi

global_configuration_file="${root_path}/config/global.env"
if [[ -f "${global_configuration_file}" ]]
  then
    . "${global_configuration_file}"
fi

if [[ ${core_functions_loaded} -ne 1 ]]
  then
    . "${root_path}/lib/core.sh"
fi

set_new_directory "${root_path}/logs"

TIMESTAMP="$(date +"%Y-%m-%d_%H-%M-%S")"
OUTPUT_DIR="./scripts/logs/${TIMESTAMP}_by_diagnostic_script"
MODE="${1:-all}" # all | app | system | platform

SYSTEM_NAMESPACES_REGEX="^(kube-system|kube-public|kube-node-lease|default)$"
PLATFORM_NAMESPACES_REGEX="^(kong|cert-manager|ingress-nginx|monitoring|argocd|cattle-system|local-path-storage)$"

mkdir -p "$OUTPUT_DIR"

generate_run_info() {

  local context
  local cluster
  local user
  local analysed_pods

  context="$(kubectl config current-context 2>/dev/null)"
  cluster="$(kubectl config view --minify -o jsonpath='{.clusters[0].name}' 2>/dev/null)"
  user="$(kubectl config view --minify -o jsonpath='{.users[0].name}' 2>/dev/null)"

  analysed_pods="$(find "$OUTPUT_DIR" -name "*_describe.txt" | wc -l)"

  cat <<EOF > "${OUTPUT_DIR}/RUN_INFO.txt"
KUBERNETES DIAGNOSTIC RUN
=========================

DATE                : $(date +"%Y-%m-%d")
TIME                : $(date +"%H:%M:%S")

MODE                : ${MODE}
COMMAND             : $0 ${MODE}

KUBECONFIG CONTEXT  : ${context}
CLUSTER             : ${cluster}
USER                : ${user}

OUTPUT DIRECTORY    : ${OUTPUT_DIR}

PODS ANALYSED       : ${analysed_pods}

GENERATED FILES
-------------------------
$(find "$OUTPUT_DIR" -type f | sed "s|${OUTPUT_DIR}/||")

EOF
}

is_system_namespace() {
  [[ "$1" =~ $SYSTEM_NAMESPACES_REGEX ]]
}

is_platform_namespace() {
  [[ "$1" =~ $PLATFORM_NAMESPACES_REGEX ]]
}

namespace_matches_mode() {
  local ns="$1"

  case "$MODE" in
    system) is_system_namespace "$ns" ;;
    platform) is_platform_namespace "$ns" ;;
    app) ! is_system_namespace "$ns" && ! is_platform_namespace "$ns" ;;
    all) return 0 ;;
    *)
      echo "Mode invalide: $MODE"
      echo "Utilisation: $0 [all|app|system|platform]"
      exit 1
      ;;
  esac
}

pod_is_problematic() {
  local status="$1"
  [[ "$status" != "Running" && "$status" != "Completed" ]]
}

collect_cluster_overview() {
  kubectl get nodes -o wide > "$OUTPUT_DIR/00_nodes.txt" 2>&1
  kubectl get ns > "$OUTPUT_DIR/00_namespaces.txt" 2>&1
  kubectl get pods -A -o wide > "$OUTPUT_DIR/00_pods_all.txt" 2>&1
  kubectl get events -A --sort-by=.lastTimestamp > "$OUTPUT_DIR/00_events_sorted.txt" 2>&1
  kubectl get events -A --sort-by=.lastTimestamp | grep -v "Normal" > "$OUTPUT_DIR/00_events_warnings.txt" 2>&1
}

describe_pod() {
  local ns="$1"
  local pod="$2"

  kubectl describe pod "$pod" -n "$ns" \
    > "$OUTPUT_DIR/${ns}_${pod}_describe.txt" 2>&1
}

logs_pod() {
  local ns="$1"
  local pod="$2"

  kubectl logs "$pod" -n "$ns" --all-containers=true \
    > "$OUTPUT_DIR/${ns}_${pod}_logs.txt" 2>&1

  kubectl logs "$pod" -n "$ns" --all-containers=true --previous \
    > "$OUTPUT_DIR/${ns}_${pod}_previous_logs.txt" 2>&1
}

diagnose_problematic_pods() {
  kubectl get pods -A --no-headers | while read -r ns pod ready status rest; do
    if namespace_matches_mode "$ns" && pod_is_problematic "$status"; then
      echo "[INFO] Pod problématique détecté: $ns/$pod ($status)"
      describe_pod "$ns" "$pod"
      logs_pod "$ns" "$pod"
    fi
  done
}

main() {
  echo "[INFO] Mode diagnostic: $MODE"

  collect_cluster_overview
  diagnose_problematic_pods

  generate_run_info

  echo "[OK] Diagnostic terminé."
  echo "[INFO] Résultats dans: $OUTPUT_DIR"
}

main
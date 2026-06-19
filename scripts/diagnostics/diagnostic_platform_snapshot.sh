#!/usr/bin/env bash

# ==============================================================================
# Fichier      : diagnostic_platform_snapshot.sh
# Description  : Snapshot lecture seule du socle Kubernetes déployé par Terraform
# Objectif     : Vérifier rapidement namespaces, pods, Helm, services, ingress, PVC
# Sécurité     : Ne modifie jamais le cluster
# Dépendances  : kubectl, helm, kubeconfig valide
# ==============================================================================

set -u

TIMESTAMP="$(date +"%Y-%m-%d_%H-%M-%S")"
OUTPUT_DIR="./scripts/logs/${TIMESTAMP}_platform_snapshot"

mkdir -p "${OUTPUT_DIR}"

section() {
  echo
  echo "============================================================================="
  echo "$1"
  echo "============================================================================="
}

run_cmd() {
  local title="$1"
  local file="$2"
  shift 2

  section "${title}" | tee -a "${OUTPUT_DIR}/SUMMARY.txt"
  echo "[CMD] $*" | tee -a "${OUTPUT_DIR}/SUMMARY.txt"

  "$@" > "${OUTPUT_DIR}/${file}" 2>&1
  local status=$?

  if [[ ${status} -eq 0 ]]; then
    echo "[OK] ${title}" | tee -a "${OUTPUT_DIR}/SUMMARY.txt"
  else
    echo "[WARN] ${title} - commande en erreur, voir ${file}" | tee -a "${OUTPUT_DIR}/SUMMARY.txt"
  fi

  return 0
}

section "Diagnostic plateforme Kubernetes"
echo "Date        : $(date)" | tee -a "${OUTPUT_DIR}/SUMMARY.txt"
echo "Output dir  : ${OUTPUT_DIR}" | tee -a "${OUTPUT_DIR}/SUMMARY.txt"

run_cmd "Contexte Kubernetes courant" "00_context.txt" kubectl config current-context
run_cmd "Informations cluster" "01_cluster_info.txt" kubectl cluster-info
run_cmd "Nodes" "02_nodes.txt" kubectl get nodes -o wide
run_cmd "Namespaces" "03_namespaces.txt" kubectl get namespaces
run_cmd "Pods tous namespaces" "04_pods_all.txt" kubectl get pods -A -o wide
run_cmd "Helm releases" "05_helm_releases.txt" helm list -A
run_cmd "Services" "06_services.txt" kubectl get svc -A -o wide
run_cmd "Ingress" "07_ingress.txt" kubectl get ingress -A
run_cmd "PVC" "08_pvc.txt" kubectl get pvc -A
run_cmd "PV" "09_pv.txt" kubectl get pv
run_cmd "Events récents" "10_events.txt" kubectl get events -A --sort-by=.lastTimestamp

section "Analyse rapide" | tee -a "${OUTPUT_DIR}/SUMMARY.txt"

echo "[CHECK] Pods non Running / non Completed" | tee -a "${OUTPUT_DIR}/SUMMARY.txt"
kubectl get pods -A --no-headers 2>/dev/null \
  | awk '$4!="Running" && $4!="Completed" {print}' \
  | tee "${OUTPUT_DIR}/11_pods_problematic.txt"

echo "[CHECK] Helm releases non deployed" | tee -a "${OUTPUT_DIR}/SUMMARY.txt"
helm list -A --no-headers 2>/dev/null \
  | awk '$8!="deployed" {print}' \
  | tee "${OUTPUT_DIR}/12_helm_not_deployed.txt"

echo "[CHECK] PVC non Bound" | tee -a "${OUTPUT_DIR}/SUMMARY.txt"
kubectl get pvc -A --no-headers 2>/dev/null \
  | awk '$3!="Bound" {print}' \
  | tee "${OUTPUT_DIR}/13_pvc_not_bound.txt"

echo "[CHECK] Events non normaux" | tee -a "${OUTPUT_DIR}/SUMMARY.txt"
kubectl get events -A --sort-by=.lastTimestamp 2>/dev/null \
  | grep -v "Normal" \
  | tee "${OUTPUT_DIR}/14_events_warnings.txt"

section "Résultat"
echo "[OK] Snapshot terminé"
echo "[INFO] Résultats disponibles dans : ${OUTPUT_DIR}"
echo "[INFO] Fichier principal : ${OUTPUT_DIR}/SUMMARY.txt"
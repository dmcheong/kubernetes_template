#!/usr/bin/env bash
#===============================================================================
# Fichier      : install_prometheus.sh
# Description  : Vérifie et installe/met à jour Prometheus + Grafana via Helm
# Dépendances  : core.sh, global.env, helm, kubectl
#===============================================================================

# definition de la racine de la stack trace
Function_PATH="/"
# definition de la racine du projet
root_path="$(dirname $(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd))"
# log date time file
log_timestamp=$(date '+%Y-%m-%d_%H_%M_%S')
# log file path
log_file="${root_path}/log/build_all_${log_timestamp}.log"

global_configuration_file="${root_path}/config/global.env"
if [[ -f "${global_configuration_file}" ]]
  then
    . "${global_configuration_file}"
fi

if [[ ${core_functions_loaded} -ne 1 ]]
  then
    . "${root_path}/lib/core.sh"
fi

function install_prometheus()
{
  set_message "info" "0" "Exécution du script d'installation des outils de monitoring [Prometheus + Grafana]"

  # création du namespace monitoring
  set_message "check" "0" "Vérification du namespace cible: ${MONITORING_NAMESPACE}"
  if ! kubectl get namespace "${MONITORING_NAMESPACE}" >/dev/null 2>&1; then
    set_message "info" "0" "Création du namespace: ${MONITORING_NAMESPACE}"
    kubectl create namespace "${MONITORING_NAMESPACE}" >/dev/null
    error_CTRL "${?}" ""
  else
    set_message "EdSMessage" "0" "Le namespace [${MONITORING_NAMESPACE}] est déjà présent"
  fi

  # ajout du repository Prometheus dans Helm
  set_message "check" "0" "Vérification du repository Helm: ${PROMETHEUS_REPO_NAME}"
  if ! helm repo list 2>/dev/null | awk 'NR>1 {print $1}' | grep -qx "${PROMETHEUS_REPO_NAME}"; then
    set_message "info" "0" "Ajout du repository Helm: ${PROMETHEUS_REPO_NAME}"
    helm repo add "${PROMETHEUS_REPO_NAME}" "${PROMETHEUS_REPO_URL}" >/dev/null
    error_CTRL "${?}" ""
  else
    set_message "EdSMessage" "0" "Le repository Helm [${PROMETHEUS_REPO_NAME}] est déjà présent dans la liste"
  fi

  # mise à jour des repositories Helm
  set_message "check" "0" "Mise à jour des repositories Helm"
  helm repo update >/dev/null
  error_CTRL "${?}" ""

  # installation / upgrade (idempotent)
  set_message "check" "0" "Vérification de la release [${PROMETHEUS_RELEASE}] dans le namespace ${MONITORING_NAMESPACE}"
  if helm status "${PROMETHEUS_RELEASE}" -n "${MONITORING_NAMESPACE}" >/dev/null 2>&1; then
    set_message "info" "0" "Release [${PROMETHEUS_RELEASE}] déjà installée -> upgrade (idempotent)"
  else
    set_message "info" "0" "Release [${PROMETHEUS_RELEASE}] absente -> installation"
  fi

  if [ -n "${VALUES_FILE:-}" ] && [ -f "${VALUES_FILE}" ]; then
    set_message "info" "0" "Déploiement via Helm de valeurs spécifiques: ${VALUES_FILE}"
    helm upgrade --install "${PROMETHEUS_RELEASE}" "${PROMETHEUS_CHART}" -n "${MONITORING_NAMESPACE}" -f "${VALUES_FILE}" --wait
  else
    set_message "info" "0" "Déploiement via Helm des valeurs par défaut"
    helm upgrade --install "${PROMETHEUS_RELEASE}" "${PROMETHEUS_CHART}" -n "${MONITORING_NAMESPACE}" --wait
  fi
  error_CTRL "${?}" ""

  set_message "info" "0" "Liste des Pods principaux dans [${MONITORING_NAMESPACE}]:"
  kubectl get pods -n "${MONITORING_NAMESPACE}" | grep -E 'prometheus|alertmanager|grafana|operator|node-exporter|kube-state-metrics' || true

  set_message "info" "0" "Liste des services dans le namespace ${MONITORING_NAMESPACE}:"
  kubectl get services -n "${MONITORING_NAMESPACE}"

  set_message "info" "0" "Pour accéder aux tableaux de bord: kubectl -n ${MONITORING_NAMESPACE} port-forward svc/${PROMETHEUS_RELEASE}-prometheus 9090:9090"
  set_message "info" "0" "Grafana (port-forward): kubectl -n ${MONITORING_NAMESPACE} port-forward svc/${PROMETHEUS_RELEASE}-grafana 3000:80"

  set_message "warn" "0" "ATTENTION: ne pas laisser l'exposition des secrets dans le code d'automatisation pour la production"
  set_message "info" "0" "Grafana admin password (modifier dès la première connexion):"
  kubectl -n "${MONITORING_NAMESPACE}" get secret "${PROMETHEUS_RELEASE}-grafana" -o jsonpath="{.data.admin-password}" 2>/dev/null | base64 -d && echo || true
}


set_message "check" "0" "Vérification de l'installation de Prometheus + Grafana"
install_prometheus

if [[ ! ${?} == "0" ]]
  then
    set_message "EdEMessage" "5" "Echec de l'installation de Prometheus + Grafana"
  else
    set_message "EdSMessage" "0" "Prometheus + Grafana opérationnels"
fi

#!/usr/bin/env bash
#===============================================================================
# Fichier      : install_opentelemetry.sh
# Description  : Vérifie et installe/met à jour OpenTelemetry Collector via Helm
# Dépendances  : core.sh, global.env, helm, kubectl
# Infos (1)    : OpenTelemetry Collector chart requires mode=daemonset|deployment|statefulset
# Infos (2)    : Pour l installation vous devez choisir/modifier "OTEL_RELEASE" dans global.env
# OTEL_RELEASE : deamonset (nods, pods, container, logs) OU deployment (cluster & events)
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

set_new_directory "${root_path}/log"

function install_opentelemetry()
{
  set_message "info" "0" "Exécution du script d'installation OpenTelemetry Collector"

  # création du namespace monitoring
  set_message "check" "0" "Vérification du namespace cible: ${MONITORING_NAMESPACE}"
  if ! kubectl get namespace "${MONITORING_NAMESPACE}" >/dev/null 2>&1; then
    set_message "info" "0" "Création du namespace: ${MONITORING_NAMESPACE}"
    kubectl create namespace "${MONITORING_NAMESPACE}" >/dev/null
    error_CTRL "${?}" ""
  else
    set_message "EdSMessage" "0" "Le namespace [${MONITORING_NAMESPACE}] est déjà présent"
  fi

  # ajout du repository OpenTelemetry dans Helm
  set_message "check" "0" "Vérification du repository Helm: ${OTEL_REPO_NAME}"
  if ! helm repo list 2>/dev/null | awk 'NR>1 {print $1}' | grep -qx "${OTEL_REPO_NAME}"; then
    set_message "info" "0" "Ajout du repository Helm: ${OTEL_REPO_NAME}"
    helm repo add "${OTEL_REPO_NAME}" "${OTEL_REPO_URL}" >/dev/null
    error_CTRL "${?}" ""
  else
    set_message "EdSMessage" "0" "Le repository Helm [${OTEL_REPO_NAME}] est déjà présent dans la liste"
  fi

  # mise à jour des repositories Helm
  set_message "check" "0" "Mise à jour des repositories Helm"
  helm repo update >/dev/null
  error_CTRL "${?}" ""

  # installation / upgrade (idempotent). OTEL_RELEASE=deployment
  set_message "check" "0" "Vérification de la release [${OTEL_RELEASE}] dans le namespace ${MONITORING_NAMESPACE}"
  if helm status "${OTEL_RELEASE}" -n "${MONITORING_NAMESPACE}" >/dev/null 2>&1; then
    set_message "info" "0" "Release [${OTEL_RELEASE}] déjà installée -> upgrade (idempotent)"
  else
    set_message "info" "0" "Release [${OTEL_RELEASE}] absente -> installation"
  fi

  if [ -n "${VALUES_FILE:-}" ] && [ -f "${VALUES_FILE}" ]; then
    set_message "info" "0" "Déploiement via Helm avec fichier de configuration: ${VALUES_FILE}"
    helm upgrade --install "${OTEL_RELEASE}" "${OTEL_CHART}" -n "${MONITORING_NAMESPACE}" -f "${VALUES_FILE}" --wait
  else
    set_message "info" "0" "Déploiement via Helm avec configuration minimale par défaut (mode=deployment)"
    helm upgrade --install "${OTEL_RELEASE}" "${OTEL_CHART}" -n "${MONITORING_NAMESPACE}" --set mode=deployment --set image.repository="otel/opentelemetry-collector-k8s" --wait
  fi
  error_CTRL "${?}" ""

  set_message "info" "0" "Liste des pods OpenTelemetry dans [${MONITORING_NAMESPACE}]:"
  kubectl get pods -n "${MONITORING_NAMESPACE}" | grep -E 'opentelemetry|otel|collector' || true

  set_message "info" "0" "Liste des services OpenTelemetry dans [${MONITORING_NAMESPACE}]:"
  kubectl get svc -n "${MONITORING_NAMESPACE}" | grep -E 'opentelemetry|otel|collector' || true
}


set_message "check" "0" "Vérification de l'installation d'OpenTelemetry Collector"
install_opentelemetry

if [[ ! ${?} == "0" ]]
  then
    set_message "EdEMessage" "5" "Echec de l'installation d'OpenTelemetry Collector"
  else
    set_message "EdSMessage" "0" "OpenTelemetry Collector opérationnel"
fi

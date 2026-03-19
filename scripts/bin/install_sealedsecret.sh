#!/usr/bin/env bash
#===============================================================================
# Fichier      : install_sealedsecret.sh
# Description  : Vérifie et installe le controller Sealed Secrets
# Dépendances  : core.sh, global.env, kubectl
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

function get_latest_github_tag()
{
  local _repo="${1}"
  curl -fsSI "https://github.com/${_repo}/releases/latest" \
    | tr -d '\r' \
    | awk -F': ' 'tolower($1)=="location"{print $2}' \
    | awk -F/ '{print $NF}' \
    | tail -n1
}

function install_sealedsecret()
{
  set_message "check" "0" "Détection de la dernière release de Sealed-Secrets"
  LATEST_TAG="$(get_latest_github_tag "${SEALEDSECRETS_REPO}")"
  error_CTRL "${?}" ""

  if [[ -z "${LATEST_TAG:-}" ]]; then
    set_message "EdEMessage" "1" "Impossible de récupérer la dernière release GitHub - vérifiez la connectivité"
  fi
  set_message "EdSMessage" "0" "Dernière release détectée: ${LATEST_TAG}"

  # vérification du controller dans le namespace kube-system
  set_message "check" "0" "Vérification du controller sealed-secrets dans le namespace kube-system"
  if kubectl -n kube-system get deploy sealed-secrets-controller >/dev/null 2>&1; then
    set_message "EdSMessage" "0" "Controller Sealed Secrets déjà installé dans le namespace kube-system"
  else
    set_message "info" "0" "Controller absent du namespace kube-system - installation depuis ${LATEST_TAG}"
    kubectl apply -f "https://github.com/${SEALEDSECRETS_REPO}/releases/download/${LATEST_TAG}/controller.yaml"
    error_CTRL "${?}" ""
  fi

  # vérification finale
  set_message "check" "0" "Vérification finale du déploiement sealed-secrets-controller"
  kubectl -n kube-system get deploy sealed-secrets-controller
  error_CTRL "${?}" ""
}


set_message "check" "0" "Vérification de l'installation de Sealed Secrets"
install_sealedsecret

if [[ ! ${?} == "0" ]]
  then
    set_message "EdEMessage" "5" "Echec de l'installation de Sealed Secrets"
  else
    set_message "EdSMessage" "0" "Sealed Secrets controller opérationnel"
fi

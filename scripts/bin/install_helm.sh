#!/usr/bin/env bash
#===============================================================================
# Fichier      : install_helm.sh
# Description  : Vérifie et installe/met à jour Helm
# Dépendances  : core.sh, global.env
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

function version_lt()
{
  [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" != "$2" ]
}

function install_helm()
{
  set_message "check" "0" "téléchargement et installation de la dernière version stable de Helm"
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  error_CTRL "${?}" ""
}

function helm_version()
{
  CURRENT_HELM_VERSION="$(helm version --short 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)"
  set_message "info" "0" "Helm détecté en version: ${CURRENT_HELM_VERSION}"

  set_message "check" "0" "Vérification compatibilité version Helm (min: ${HELM_MIN_VERSION})"
  if [ -z "${CURRENT_HELM_VERSION}" ]
    then
      set_message "EdEMessage" "5" ""
      set_message "info" "0""Impossible de déterminer la version de Helm"
    else
      version_lt "${CURRENT_HELM_VERSION}" "${HELM_MIN_VERSION}"
      if [[ ${?} -eq 0 ]]
        then
          set_message "EdWMessage" "0" "Helm n'est pas à jour (actuelle: ${CURRENT_HELM_VERSION}, min: ${HELM_MIN_VERSION}) - mise à jour"
          install_helm
        else
          set_message "EdSMessage" "0" "Helm à jour (actuelle: ${CURRENT_HELM_VERSION}, min: ${HELM_MIN_VERSION})"
      fi
    fi
}


set_message "check" "0" "Vérification de l installation du service Helm"
command -v helm > /dev/null 2>&1

if [[ ! ${?} == "0" ]]
  then
    set_message "EdWMessage" "0" "Helm absent - installation de la dernière version stable"
    install_helm
    set_message "check" "0" "Vérification de l installation du service Helm"
    command -v helm > /dev/null 2>&1
    if [[ ! ${?} == "0" ]]
      then
        set_message "EdEMessage" "5" "Echec de l installation de Helm"
      else
        set_message "EdSMessage" "0" "Helm installé avec succès"
    fi
  else
    set_message "EdSMessage" "0" "Helm présent"
    helm_version
fi

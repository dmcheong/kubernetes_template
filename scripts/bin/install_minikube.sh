#!/usr/bin/env bash
#===============================================================================
# Fichier      : install_minikube.sh
# Description  : Vérifie et installe/met à jour Minikube
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

function version_lt()
{
  [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" != "$2" ]
}

function install_minikube()
{
  set_message "check" "0" "téléchargement du binaire minikube"
  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  error_CTRL "${?}" ""

  set_message "check" "0" "installation de minikube vers /usr/local/bin/"
  sudo install minikube-linux-amd64 /usr/local/bin/minikube
  error_CTRL "${?}" ""

  set_message "check" "0" "nettoyage de l'archive minikube"
  rm minikube-linux-amd64
  error_CTRL "${?}" ""
}

function minikube_version()
{
  CURRENT_MINIKUBE_VERSION="$(minikube version --short 2>/dev/null | sed 's/^v//')"
  set_message "info" "0" "Minikube détecté en version: ${CURRENT_MINIKUBE_VERSION}"

  set_message "check" "0" "Vérification compatibilité version Minikube (min: ${MINIKUBE_MIN_VERSION})"
  if [ -z "${CURRENT_MINIKUBE_VERSION}" ]
    then
      set_message "EdEMessage" "5" "Impossible de déterminer la version de Minikube"
    else
      version_lt "${CURRENT_MINIKUBE_VERSION}" "${MINIKUBE_MIN_VERSION}"
      if [[ ${?} -eq 0 ]]
        then
          set_message "EdWMessage" "0" "Minikube n'est pas à jour (actuelle: ${CURRENT_MINIKUBE_VERSION}, min: ${MINIKUBE_MIN_VERSION}) - mise à jour"
          install_minikube
        else
          set_message "EdSMessage" "0" "Minikube à jour (actuelle: ${CURRENT_MINIKUBE_VERSION}, min: ${MINIKUBE_MIN_VERSION})"
      fi
    fi
}


set_message "check" "0" "Vérification de l'installation du cluster Minikube"
command -v minikube > /dev/null 2>&1

if [[ ! ${?} == "0" ]]
  then
    set_message "EdWMessage" "0" "Minikube absent - installation de la dernière version stable"
    install_minikube
    set_message "check" "0" "Vérification de l'installation du cluster Minikube"
    command -v minikube > /dev/null 2>&1
    if [[ ! ${?} == "0" ]]
      then
        set_message "EdEMessage" "5" "Echec de l'installation de Minikube"
      else
        set_message "EdSMessage" "0" "Minikube installé avec succès"
    fi
  else
    set_message "EdSMessage" "0" "Minikube présent"
    minikube_version
fi

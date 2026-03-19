#!/usr/bin/env bash
#===============================================================================
# Fichier      : install_kubectl.sh
# Description  : Vérifie et installe/met à jour kubectl
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

function install_kubectl() 
{
  set_message "check" "0" "téléchargement de la dernière version stable de kubectl"
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  error_CTRL "${?}" ""
    
  set_message "check" "0" "changement des permissions pour kubectl"
  chmod +x kubectl
  error_CTRL "${?}" ""

  set_message "check" "0" "déplacement de kubectl vers /usr/local/bin/"
  sudo mv kubectl /usr/local/bin/
  error_CTRL "${?}" ""
}

function kubectl_version()
{
  CURRENT_KUBECTL_VERSION="$(kubectl version --client 2>/dev/null | awk -F': ' '/Client Version/ {gsub(/^v/,"",$2); print $2; exit}')"
  set_message "info" "0" "kubectl détecté en version: ${CURRENT_KUBECTL_VERSION}"

  set_message "check" "0" "Vérification compatibilité version kubectl (min: ${KUBECTL_VERSION})"
  if [ -z "${CURRENT_KUBECTL_VERSION}" ]
    then
      set_message "EdEMessage" "5" "Impossible de déterminer la version de kubectl"
    else
      version_lt "${CURRENT_KUBECTL_VERSION}" "${KUBECTL_VERSION}"
      if [[ ${?} -eq 0 ]]
        then
          set_message "EdWMessage" "0" "kubectl n'est pas à jour (actuelle: ${CURRENT_KUBECTL_VERSION}, min: ${KUBECTL_VERSION}) - mise à jour"
          install_kubectl
        else
          set_message "EdSMessage" "0" "kubectl à jour (actuelle: ${CURRENT_KUBECTL_VERSION}, min: ${KUBECTL_VERSION})"
      fi
    fi
}


set_message "check" "0" "Vérification de l'installation du binaire kubectl"
command -v kubectl > /dev/null 2>&1

if [[ ! ${?} == "0" ]]
  then
    set_message "EdwMessage" "0" "kubectl absent - installation nécessaire"
    install_kubectl
    set_message "check" "0" "Vérification de l'installation du binaire kubectl"
    command -v kubectl > /dev/null 2>&1
    if [[ ! ${?} == "0" ]]
      then   
        set_message "EdEMessage" "5" "Echec de l'installation de kubectl"
      else
        set_message "EdSMessage" "0" "kubectl installé avec succès"
    fi
 else 
  set_message "EdSMessage" "0" "kubectl présent"
fi 


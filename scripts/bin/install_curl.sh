#!/usr/bin/env bash
#===============================================================================
# Fichier      : install_curl.sh
# Description  : Vérifie et installe/met à jour curl
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

function install_curl() 
{

  Do_apt_update
  Do_apt_install_package "curl"

}

function curl_version()
{
  CURRENT_CURL_VERSION="$(curl --version 2>/dev/null | head -n1 | awk '{print $2}')"
  set_message "info" "0" "curl détecté en version: ${CURRENT_CURL_VERSION}"

  set_message "check" "0" "Vérification compatibilité version curl (min: ${CURL_VERSION})"
  if [ -z "${CURRENT_CURL_VERSION}" ]
    then
      set_message "EdEMessage" "5" "Impossible de déterminer la version de curl"
    else
      version_lt "${CURRENT_CURL_VERSION}" "${CURL_VERSION}"
      if [[ ${?} -eq 0 ]]
        then
          set_message "EdWMessage" "0" "curl n'est pas à jour (actuelle: ${CURRENT_CURL_VERSION}, min: ${CURL_VERSION}) - mise à jour"
          install_curl
        else
          set_message "EdSMessage" "0" "curl à jour (actuelle: ${CURRENT_CURL_VERSION}, min: ${CURL_VERSION})"
      fi
    fi
}

#─────────────────────────────────────────────────────────────────────────────
# Vérification de l'installation du binaire curl
#─────────────────────────────────────────────────────────────────────────────
set_message "check" "0" "Vérification de l'installation du binaire curl"
command -v curl > /dev/null 2>&1

if [[ ! ${?} == "0" ]]
  then
    set_message "EdWMessage" "0" "curl absent - installation nécessaire"
    install_curl

    set_message "check" "0" "Vérification de l'installation du binaire curl"
    command -v curl > /dev/null 2>&1
    if [[ ! ${?} == "0" ]]
      then   
        set_message "EdEMessage" "5" "Echec de l'installation de curl"
      else
        set_message "EdSMessage" "0" "curl installé avec succès"
    fi
else 
  set_message "EdSMessage" "0" "curl présent"
  curl_version
fi
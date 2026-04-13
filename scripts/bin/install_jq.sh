#!/usr/bin/env bash
#===============================================================================
# Fichier      : install_jq.sh
# Description  : Vérifie et installe/met à jour jq
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

function install_jq() 
{
  set_message "check" "0" "téléchargement de la dernière version stable de jq"
  curl -L -o jq "https://github.com/stedolan/jq/releases/latest/download/jq-linux-amd64"
  error_CTRL "${?}" ""
    
  set_message "check" "0" "changement des permissions pour jq"
  chmod +x jq
  error_CTRL "${?}" ""

  set_message "check" "0" "déplacement de jq vers /usr/local/bin/"
  sudo mv jq /usr/local/bin/
  error_CTRL "${?}" ""
}

function jq_version()
{
  CURRENT_JQ_VERSION="$(jq --version 2>/dev/null | sed 's/jq-//')"
  set_message "info" "0" "jq détecté en version: ${CURRENT_JQ_VERSION}"

  set_message "check" "0" "Vérification compatibilité version jq (min: ${JQ_VERSION})"
  if [ -z "${CURRENT_JQ_VERSION}" ]
    then
      set_message "EdEMessage" "5" "Impossible de déterminer la version de jq"
    else
      version_lt "${CURRENT_JQ_VERSION}" "${JQ_VERSION}"
      if [[ ${?} -eq 0 ]]
        then
          set_message "EdWMessage" "0" "jq n'est pas à jour (actuelle: ${CURRENT_JQ_VERSION}, min: ${JQ_VERSION}) - mise à jour"
          install_jq
        else
          set_message "EdSMessage" "0" "jq à jour (actuelle: ${CURRENT_JQ_VERSION}, min: ${JQ_VERSION})"
      fi
    fi
}

set_message "check" "0" "Vérification de l'installation du binaire jq"
command -v jq > /dev/null 2>&1

if [[ ! ${?} == "0" ]]
  then
    set_message "EdWMessage" "0" "jq absent - installation nécessaire"
    install_jq

    set_message "check" "0" "Vérification de l'installation du binaire jq"
    command -v jq > /dev/null 2>&1
    if [[ ! ${?} == "0" ]]
      then   
        set_message "EdEMessage" "5" "Echec de l'installation de jq"
      else
        set_message "EdSMessage" "0" "jq installé avec succès"
    fi
else 
  set_message "EdSMessage" "0" "jq présent"
  jq_version
fi
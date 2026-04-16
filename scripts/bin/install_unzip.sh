#!/usr/bin/env bash
#===============================================================================
# Fichier      : install_unzip.sh
# Description  : Vérifie et installe unzip
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

function install_unzip() 
{
  set_message "check" "0" "mise à jour des dépôts apt"
  sudo apt-get update
  error_CTRL "${?}" ""

  set_message "check" "0" "installation de unzip"
  sudo apt-get install -y unzip
  error_CTRL "${?}" ""
}

function unzip_version()
{
  CURRENT_UNZIP_VERSION="$(unzip -v 2>/dev/null | head -n1 | awk '{print $2}')"
  set_message "info" "0" "unzip détecté en version: ${CURRENT_UNZIP_VERSION}"

  if [ -z "${CURRENT_UNZIP_VERSION}" ]
    then
      set_message "EdEMessage" "5" "Impossible de déterminer la version de unzip"
    else
      set_message "EdSMessage" "0" "unzip opérationnel"
  fi
}

#─────────────────────────────────────────────────────────────────────────────
# Vérification de l'installation du binaire unzip
#─────────────────────────────────────────────────────────────────────────────
set_message "check" "0" "Vérification de l'installation du binaire unzip"
command -v unzip > /dev/null 2>&1

if [[ ! ${?} == "0" ]]
  then
    set_message "EdWMessage" "0" "unzip absent - installation nécessaire"
    install_unzip

    set_message "check" "0" "Vérification de l'installation du binaire unzip"
    command -v unzip > /dev/null 2>&1
    if [[ ! ${?} == "0" ]]
      then   
        set_message "EdEMessage" "5" "Echec de l'installation de unzip"
      else
        set_message "EdSMessage" "0" "unzip installé avec succès"
    fi
else 
  set_message "EdSMessage" "0" "unzip présent"
fi

#─────────────────────────────────────────────────────────────────────────────
# Vérification version
#─────────────────────────────────────────────────────────────────────────────
unzip_version
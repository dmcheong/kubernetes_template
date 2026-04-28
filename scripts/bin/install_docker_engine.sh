#!/usr/bin/env bash

#===============================================================================
# Fichier      : install_docker_engine.sh
# Description  : Vérifie la version de Docker Engine
# Dépendances  : core.sh, global.env
#===============================================================================

# definition de la racine de la stack trace
Function_PATH="/"
# definition de la racine du projet
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root_path="$(dirname "$script_dir")"
# root_path="$(dirname $(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd))"
# log date time file
log_timestamp=$(date '+%Y-%m-%d_%H_%M_%S')
# log file path
log_file="${root_path}/log/build_all_${log_timestamp}.log"

global_configuration_file="${root_path}/config/global.env"
if [[ -f "${global_configuration_file}" ]] then
    . "${global_configuration_file}"
fi

if [[ ${core_functions_loaded:-0} -ne 1 ]] then
    . "${root_path}/lib/core.sh"
fi

set_new_directory "${root_path}/log"

function version_lt()
{
  [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" != "$2" ]
}

function docker_version()
{
  CURRENT_VERSION="$(docker version --format '{{.Server.Version}}' 2>/dev/null || true)"

  set_message "check" "0" "Détermination de la version Docker installée"
  if [ -z "${CURRENT_VERSION}" ]
    then
      set_message "EdEMessage" "1" "Impossible de déterminer la version de Docker - vérifiez que le daemon Docker fonctionne"
    else
      set_message "EdSMessage" "0" "Version Docker Engine détectée: ${CURRENT_VERSION}"
  fi

  set_message "check" "0" "Vérification compatibilité version Docker (min: ${MIN_DOCKER_VERSION})"
  version_lt "${CURRENT_VERSION}" "${MIN_DOCKER_VERSION}" > /dev/null 2>&1
  if [[ ${?} -eq 0 ]]
    then
      set_message "EdEMessage" "1" "Version Docker trop ancienne (installée: ${CURRENT_VERSION}, min: ${MIN_DOCKER_VERSION})"
    else
      set_message "EdSMessage" "0" "La version de Docker Engine est compatible: ${CURRENT_VERSION}"
  fi
}

set_message "check" "0" "Vérification de Docker Engine"
command -v docker > /dev/null 2>&1

if [[ ! ${?} == "0" ]]
  then
    set_message "EdEMessage" "1" "Docker n'est pas installé - veuillez installer Docker Engine avant de continuer"
  else
    set_message "EdSMessage" "0" "docker présent"
    docker_version
fi

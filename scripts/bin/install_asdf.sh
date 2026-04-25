#!/usr/bin/env bash
#===============================================================================
# Fichier      : install_asdf.sh
# Description  : Vérifie et installe/met à jour asdf
# Dépendances  : core.sh, global.env
#===============================================================================

# definition de la racine de la stack trace
Function_PATH="/"
# definition de la racine du projet
if [ -z ${root_path} ]
   then 
    export root_path="$(dirname $(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd))"
fi
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


# for binary user, here for asdf
LOCAL_BIN="$HOME/.local/bin"
set_new_directory "${LOCAL_BIN}"
export PATH="${LOCAL_BIN}:${PATH}"

function version_lt()
{
  [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" != "$2" ]
}

function install_asdf()
{

  Internet_Http_Get "https://github.com/asdf-vm/asdf/releases/download/v${ASDF_TARGET_VERSION}" "asdf-v${ASDF_TARGET_VERSION}-linux-amd64.tar.gz" "${root_path}/downloads" 

  cd ${root_path}/downloads
  set_message "check" "0" "extraction de l archive asdf vers ${LOCAL_BIN}"
  tar -xzf "asdf-v${ASDF_TARGET_VERSION}-linux-amd64.tar.gz" -C "${LOCAL_BIN}"
  error_CTRL "${?}" ""

  set_message "check" "0" "changement des permissions pour asdf"
  chmod +x "${LOCAL_BIN}/asdf"
  error_CTRL "${?}" ""

  set_message "check" "0" "nettoyage de l archive asdf"
  rm -f "asdf-v${ASDF_TARGET_VERSION}-linux-amd64.tar.gz"
  error_CTRL "${?}" ""
}

function asdf_version()
{
  CURRENT_ASDF_VERSION="$(asdf version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)"
  set_message "info" "0" "asdf détecté en version: ${CURRENT_ASDF_VERSION}"

  set_message "check" "0" "Vérification compatibilité version asdf (min: ${ASDF_MIN_VERSION})"
  if [ -z "${CURRENT_ASDF_VERSION}" ]
    then
      set_message "EdEMessage" "5" "Impossible de déterminer la version de asdf"
    else
      version_lt "${CURRENT_ASDF_VERSION}" "${ASDF_MIN_VERSION}"
      if [[ ${?} -eq 0 ]]
        then
          set_message "EdWMessage" "0" "asdf n est pas à jour (actuelle: ${CURRENT_ASDF_VERSION}, min: ${ASDF_MIN_VERSION}) - mise à jour"
          install_asdf
        else
          set_message "EdSMessage" "0" "asdf à jour (actuelle: ${CURRENT_ASDF_VERSION}, min: ${ASDF_MIN_VERSION})"
      fi
    fi
}


set_message "check" "0" "Vérification de l installation de l outil asdf"
command -v asdf > /dev/null 2>&1

if [[ ! ${?} == "0" ]]
  then
    set_message "EdWMessage" "0" "asdf absent - installation de la version ${ASDF_TARGET_VERSION}"
    install_asdf
    set_message "check" "0" "Vérification de l installation de l'outil asdf"
    command -v asdf > /dev/null 2>&1
    if [[ ! ${?} == "0" ]]
      then
        set_message "EdEMessage" "5" "Echec de l installation de asdf"
      else
        set_message "EdSMessage" "0" "asdf installé avec succès"
    fi
  else
    set_message "EdSMessage" "0" "asdf présent"
    asdf_version
fi

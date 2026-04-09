#!/usr/bin/env bash
#===============================================================================
# Fichier      : install_kubeseal.sh
# Description  : Vérifie et installe/met à jour kubeseal via asdf
# Dépendances  : core.sh, global.env, asdf
#===============================================================================

# definition de la racine de la stack trace
Function_PATH="/"
# definition de la racine du projet
root_path="$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")"
# log date time file
log_timestamp="$(date '+%Y-%m-%d_%H_%M_%S')"
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
  [ "$(printf '%s\n' "${1}" "${2}" | sort -V | head -n1)" != "${2}" ]
}

# set path for asdf library
export PATH="${HOME}/.asdf/bin:${HOME}/.asdf/shims:${PATH}"

function install_kubeseal()
{
  set_message "check" "0" "ajout du plugin kubeseal à asdf (idempotent)"
  asdf plugin add kubeseal https://github.com/crainte/asdf-kubeseal.git >/dev/null 2>&1 || true

  set_message "check" "0" "installation de kubeseal version ${KUBESEAL_TARGET_VERSION} via asdf"
  asdf install kubeseal "${KUBESEAL_TARGET_VERSION}" >/dev/null
  error_CTRL "${?}" ""

  set_message "check" "0" "activation de kubeseal version ${KUBESEAL_TARGET_VERSION}"
  asdf set kubeseal "${KUBESEAL_TARGET_VERSION}" >/dev/null
  error_CTRL "${?}" ""

  set_message "check" "0" "reconstruction des shims asdf"
  asdf reshim kubeseal >/dev/null 2>&1 || true
}

function kubeseal_version()
{
  CURRENT_KUBESEAL_VERSION="$(kubeseal --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)"
  set_message "info" "0" "kubeseal détecté en version: ${CURRENT_KUBESEAL_VERSION}"

  set_message "check" "0" "Vérification de la version kubeseal installée"
  if [ -z "${CURRENT_KUBESEAL_VERSION}" ]
    then
      set_message "EdEMessage" "5" "Impossible de déterminer la version kubeseal"
    else
      version_lt "${CURRENT_KUBESEAL_VERSION}" "${KUBESEAL_MIN_VERSION}"
      if [[ ${?} -eq 0 ]]
        then
          set_message "EdEMessage" "5" "kubeseal n'est pas à jour (actuelle: ${CURRENT_KUBESEAL_VERSION}, min: ${KUBESEAL_MIN_VERSION})"
        else
          set_message "EdSMessage" "0" "La version actuelle de kubeseal est à jour: ${CURRENT_KUBESEAL_VERSION}"
      fi
  fi
}

set_message "check" "0" "Vérification de l'installation de kubeseal"
command -v kubeseal >/dev/null 2>&1

if [[ ! ${?} == "0" ]]
  then
    set_message "EdWMessage" "0" "kubeseal absent - installation version ${KUBESEAL_TARGET_VERSION} via asdf"
    install_kubeseal
    set_message "check" "0" "Vérification de l'installation de kubeseal"
    command -v kubeseal >/dev/null 2>&1
    if [[ ! ${?} == "0" ]]
      then
        set_message "EdEMessage" "5" "Echec de l'installation de kubeseal"
      else
        set_message "EdSMessage" "0" "kubeseal installé avec succès"
    fi
  else
    set_message "EdSMessage" "0" "kubeseal présent"
    kubeseal_version
fi
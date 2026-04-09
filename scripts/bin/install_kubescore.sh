#!/usr/bin/env bash
#===============================================================================
# Fichier      : install_kubescore.sh
# Description  : Vérifie et installe/met à jour kube-score via asdf
# Dépendances  : core.sh, global.env, asdf
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

# set path for asdf library
export PATH="${HOME}/.asdf/bin:${HOME}/.asdf/shims:${PATH}"

function install_kubescore()
{
  set_message "check" "0" "ajout du plugin kube-score à asdf (idempotent)"
  asdf plugin add kube-score https://github.com/bageljp/asdf-kube-score.git >/dev/null 2>&1 || true

  set_message "check" "0" "installation de kube-score version ${KUBESCORE_TARGET_VERSION} via asdf"
  asdf install kube-score "${KUBESCORE_TARGET_VERSION}" >/dev/null
  error_CTRL "${?}" ""

  set_message "check" "0" "activation de kube-score version ${KUBESCORE_TARGET_VERSION}"
  asdf set kube-score "${KUBESCORE_TARGET_VERSION}" >/dev/null
  error_CTRL "${?}" ""

  set_message "check" "0" "reconstruction des shims asdf"
  asdf reshim kube-score >/dev/null 2>&1 || true
}

function kubescore_version()
{
  CURRENT_KUBESCORE_VERSION="$(kube-score version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)"
  set_message "info" "0" "kube-score détecté en version: ${CURRENT_KUBESCORE_VERSION}"

  set_message "check" "0" "Vérification de la version kube-score installée"
  if [ -z "${CURRENT_KUBESCORE_VERSION}" ]
    then
      set_message "EdEMessage" "5" "Impossible de déterminer la version kube-score"
    else
      version_lt "${CURRENT_KUBESCORE_VERSION}" "${KUBESCORE_MIN_VERSION}"
      if [[ ${?} -eq 0 ]]
        then
          set_message "EdEMessage" "5" "kube-score n'est pas à jour (actuelle: ${CURRENT_KUBESCORE_VERSION}, min: ${KUBESCORE_MIN_VERSION})"
        else
          set_message "EdSMessage" "0" "La version actuelle de kube-score est à jour: ${CURRENT_KUBESCORE_VERSION}"
      fi
    fi
}


set_message "check" "0" "Vérification de l'installation de kube-score"
command -v kube-score > /dev/null 2>&1

if [[ ! ${?} == "0" ]]
  then
    set_message "EdWMessage" "0" "kube-score absent - installation version ${KUBESCORE_TARGET_VERSION} via asdf"
    install_kubescore
    set_message "check" "0" "Vérification de l'installation de kube-score"
    command -v kube-score > /dev/null 2>&1
    if [[ ! ${?} == "0" ]]
      then
        set_message "EdEMessage" "5" "Echec de l'installation de kube-score"
      else
        set_message "EdSMessage" "0" "kube-score installé avec succès"
    fi
  else
    set_message "EdSMessage" "0" "kube-score présent"
    kubescore_version
fi

# Install specific version
# asdf install kube-score latest

# Set a version globally (on your ~/.tool-versions file)
# asdf global kube-score latest
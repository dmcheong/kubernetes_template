#!/usr/bin/env bash
#===============================================================================
# Fichier      : install_awscli.sh
# Description  : Vérifie et installe/configure AWS CLI (version officielle v2)
# Dépendances  : core.sh, global.env, curl, unzip
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


function install_awscli() 
{
  Internet_Http_Get "https://awscli.amazonaws.com" "awscli-exe-linux-x86_64.zip" "${root_path}/downloads" 
  
  cd ${root_path}/downloads 

  set_message "check" "0" "décompression de l'archive AWS CLI"
  unzip -o awscliv2.zip
  error_CTRL "${?}" "Décompression du fichier réussi"

  set_message "check" "0" "installation de AWS CLI"
  sudo ./aws/install --update
  error_CTRL "${?}" "Installation réussi"

  set_message "check" "0" "nettoyage des fichiers temporaires"
  rm -rf aws awscliv2.zip
  error_CTRL "${?}" "Nettoyage après installation réussi"

  cd ${root_path}
}

function awscli_version()
{
  CURRENT_AWS_VERSION="$(aws --version 2>/dev/null | awk '{print $1}' | cut -d/ -f2)"
  set_message "info" "0" "aws cli détecté en version: ${CURRENT_AWS_VERSION}"

  if [ -z "${CURRENT_AWS_VERSION}" ]
    then
      set_message "EdEMessage" "5" "Impossible de déterminer la version de aws cli"
    else
      set_message "EdSMessage" "0" "aws cli opérationnel"
  fi
}

function awscli_configure()
{
  set_message "info" "0" "configuration de aws cli (mode non interactif)"
   
  set_message "check" "0" "configure set aws_access_key_id"
  aws configure set aws_access_key_id "test"  > /dev/null 2>&1 
  error_CTRL "${?}" ""

  set_message "check" "0" "configure : set aws_secret_access_key"
  aws configure set aws_secret_access_key "test" > /dev/null 2>&1 
  error_CTRL "${?}" ""

  set_message "check" "0" "configure : set region"
  aws configure set region "us-east-1" > /dev/null 2>&1 
  error_CTRL "${?}" ""

  set_message "check" "0" "configure : set output"
  aws configure set output "json" > /dev/null 2>&1 
  error_CTRL "${?}" ""

  set_message "info" "0" "configuration aws cli terminée"
}

#─────────────────────────────────────────────────────────────────────────────
# Vérification de l'installation aws cli
#─────────────────────────────────────────────────────────────────────────────
set_message "check" "0" "Vérification de l'installation du binaire aws"
command -v aws > /dev/null 2>&1

if [[ ! ${?} == "0" ]]
  then
    set_message "EdWMessage" "0" "aws cli absent - installation nécessaire"
    install_awscli

    set_message "check" "0" "Vérification de l'installation du binaire aws"
    command -v aws > /dev/null 2>&1
    if [[ ! ${?} == "0" ]]
      then   
        set_message "EdEMessage" "5" "Echec de l'installation de aws cli"
      else
        set_message "EdSMessage" "0" "aws cli installé avec succès"
    fi
else 
  set_message "EdSMessage" "0" "aws cli présent"
fi

#─────────────────────────────────────────────────────────────────────────────
# Vérification version + configuration
#─────────────────────────────────────────────────────────────────────────────
awscli_version
awscli_configure
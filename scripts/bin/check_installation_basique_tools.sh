#!/usr/bin/env bash

#===============================================================================
# Fichier      : check_installation_basique_tools.sh
# Description  : Vérifie et installe tous les outils de base
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

# function to comparison tools, use like this:
# version_lt "CURRENT_VERSION_TOOL" "TOOL_MINIMUM_VERSION"
function version_lt()
{
  # true (0) si $1 < $2
  [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" != "$2" ]
}

set_message "info" "0" "Exécution du script de vérification des outils de base"

# curl
do_load_file "${root_path}/bin/install_curl.sh" "curl install script"


# docker
do_load_file "${root_path}/bin/install_docker_engine.sh" "docker install script"


# helm
do_load_file "${root_path}/bin/install_helm.sh" "helm install script"


# kubectl

do_load_file "${root_path}/bin/install_kubectl.sh" "kubectl install script"


# Minikube
do_load_file "${root_path}/bin/install_minikube.sh" "Minikube install script"


# asdf
do_load_file "${root_path}/bin/install_asdf.sh" "adsf install script"


# jq
do_load_file "${root_path}/bin/install_jq.sh" "jq install script"


# kube-score
do_load_file "${root_path}/bin/install_kubescore.sh" "kube-score install script"


# kubeseal
do_load_file "${root_path}/bin/install_kubeseal.sh" "kubeseal NFS installation script"

# sealedsecret
do_load_file "${root_path}/bin/install_sealedsecret.sh" "initialization script"



printf "%b\n"
set_message "info" "0" "Tous les outils de base sont vérifiés (helm, kubectl, minikube, asdf, jq, kube-score, kubeseal, sealedsecret)"
printf "%b\n"
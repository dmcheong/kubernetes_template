#!/usr/bin/env bash
#===============================================================================
# Fichier      : check_installation_basique_tools.sh
# Description  : Vérifie et installe tous les outils de base
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

# function to comparison tools, use like this:
# version_lt "CURRENT_VERSION_TOOL" "TOOL_MINIMUM_VERSION"
version_lt()
{
  # true (0) si $1 < $2
  [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" != "$2" ]
}

set_message "info" "0" "Exécution du script de vérification des outils de base"

# docker
set_message "check" "0" "Chargement du script d'installation Docker"
source "${root_path}/bin/install_docker_engine.sh"
if [[ ${?} -eq 0 ]]
  then
    set_message "EdSMessage" "0" "Docker vérifié"
  else
    set_message "EdEMessage" "5" "Echec de la vérification Docker"
fi

# helm
set_message "check" "0" "Chargement du script d'installation Helm"
source "${root_path}/bin/install_helm.sh"
if [[ ${?} -eq 0 ]]
  then
    set_message "EdSMessage" "0" "Helm vérifié"
  else
    set_message "EdEMessage" "5" "Echec de la vérification Helm"
fi

# kubectl
set_message "check" "0" "Chargement du script d'installation kubectl"
source "${root_path}/bin/install_kubectl.sh"
if [[ ${?} -eq 0 ]]
  then
    set_message "EdSMessage" "0" "kubectl vérifié"
  else
    set_message "EdEMessage" "5" "Echec de la vérification kubectl"
fi

# Minikube
set_message "check" "0" "Chargement du script d'installation Minikube"
source "${root_path}/bin/install_minikube.sh"
if [[ ${?} -eq 0 ]]
  then
    set_message "EdSMessage" "0" "Minikube vérifié"
  else
    set_message "EdEMessage" "5" "Echec de la vérification Minikube"
fi

# asdf
set_message "check" "0" "Chargement du script d'installation asdf"
source "${root_path}/bin/install_asdf.sh"
if [[ ${?} -eq 0 ]]
  then
    set_message "EdSMessage" "0" "asdf vérifié"
  else
    set_message "EdEMessage" "5" "Echec de la vérification asdf"
fi

# kube-score
set_message "check" "0" "Chargement du script d'installation kube-score"
source "${root_path}/bin/install_kubescore.sh"
if [[ ${?} -eq 0 ]]
  then
    set_message "EdSMessage" "0" "kube-score vérifié"
  else
    set_message "EdEMessage" "5" "Echec de la vérification kube-score"
fi

# kubeseal
set_message "check" "0" "Chargement du script d'installation kubeseal NFS"
source "${root_path}/bin/install_kubeseal.sh"
if [[ ${?} -eq 0 ]]
  then
    set_message "EdSMessage" "0" "kubeseal NFS vérifié"
  else
    set_message "EdEMessage" "5" "Echec de la vérification kubeseal NFS"
fi

# sealedsecret
set_message "check" "0" "Chargement du script d'installation Sealed Secrets"
source "${root_path}/bin/install_sealedsecret.sh"
if [[ ${?} -eq 0 ]]
  then
    set_message "EdSMessage" "0" "Sealed Secrets vérifié"
  else
    set_message "EdEMessage" "5" "Echec de la vérification Sealed Secrets"
fi

set_message "EdSMessage" "0" "Tous les outils de base sont vérifiés (helm, kubectl, minikube, asdf, kube-score, kubeseal, sealedsecret)"
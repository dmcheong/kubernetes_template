#!/usr/bin/env bash
#===============================================================================
# Fichier      : clean_env_dev.sh
# Description  : Purge l'environnement de développement (suppression namespace dev)
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

function clean_env_dev()
{
  # la suppression du namespace supprime également les pods et autres ressources
  set_message "check" "0" "Suppression des namespaces dev et monitoring"
  kubectl delete namespace dev "${MONITORING_NAMESPACE}"
  error_CTRL "${?}" ""

  set_message "EdSMessage" "0" "Namespaces supprimés"
}


set_message "check" "0" "Nettoyage de l'environnement de développement"
clean_env_dev

if [[ ! ${?} == "0" ]]
  then
    set_message "EdEMessage" "5" "Echec du nettoyage de l'environnement"
  else
    set_message "EdSMessage" "0" "Environnement nettoyé avec succès"
fi

# pour réinitialiser complètement, depuis la racine ($HOME ou $USER) :
# minikube delete --all --purge
# rm -rf ~/.asdf

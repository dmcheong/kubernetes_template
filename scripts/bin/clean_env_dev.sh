#!/usr/bin/env bash
#===============================================================================
# Fichier      : clean_env_dev.sh
# Description  : Purge l'environnement de développement (suppression namespace dev)
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

function clean_env_dev()
{
  # la suppression du namespace supprime également les pods et autres ressources
  set_message "check" "0" "Suppression des différents namespaces automatiquement déployés comme dev + monitoring + traefik + kong + (autres)"
  kubectl delete namespace dev ingress-nginx kong kubernetes-dashboard treafik "${MONITORING_NAMESPACE}"
  error_CTRL "${?}" ""
}


set_message "info" "0" "Nettoyage de l'environnement de développement"
clean_env_dev


# pour réinitialiser complètement, depuis la racine ($HOME ou $USER) :
# minikube delete --all --purge
# rm -rf ~/.asdf
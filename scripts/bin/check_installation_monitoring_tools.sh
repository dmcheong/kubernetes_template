#!/usr/bin/env bash
#===============================================================================
# Fichier      : check_installation_monitoring_tools.sh
# Description  : Vérifie et installe tous les outils de monitoring
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

set_message "info" "0" "Exécution du script de vérification des outils de monitoring"

# prometheus + grafana
set_message "check" "0" "Chargement du script d installation Prometheus + Grafana"
source "${root_path}/bin/install_prometheus.sh"
if [[ ${?} -eq 0 ]]
  then
    set_message "EdSMessage" "0" "Prometheus + Grafana vérifiés"
  else
    set_message "EdEMessage" "5" "Echec de la vérification Prometheus + Grafana"
fi

# open-telemetry
set_message "check" "0" "Chargement du script d'installation OpenTelemetry"
source "${root_path}/bin/install_opentelemetry.sh"
if [[ ${?} -eq 0 ]]
  then
    set_message "EdSMessage" "0" "OpenTelemetry vérifié"
  else
    set_message "EdEMessage" "5" "Echec de la vérification OpenTelemetry"
fi

set_message "EdSMessage" "0" "Les services de monitoring Prometheus, Grafana et OpenTelemetry sont vérifiés"
#!/usr/bin/env bash
#===============================================================================
# Fichier      : script_test_namespace_monitoring.sh
# Description  : Test et gestion du namespace monitoring en local
# Prérequis    : kubectl disponible, cluster actif (minikube ou autre)
#===============================================================================
global_configuration_file="${root_path}/config/global.env"
if [[ -f "${global_configuration_file}" ]]
  then
    . "${global_configuration_file}"
fi

set_message "info" "0" "Gestion du namespace ${MONITORING_NAMESPACE}."
printf "\n"

# Activation du mode debug
DEBUG_MODE="1"

#─────────────────────────────────────────────────────────────────────────────
# Vue d'ensemble des namespaces existants
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Liste de tous les namespaces:"
kubectl get namespaces

#
#─────────────────────────────────────────────────────────────────────────────
# Création du namespace monitoring (idempotent)
# Le namespace monitoring est utilisé pour les outils de supervision
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Création d un environnement namespace -> ${MONITORING_NAMESPACE}:"
if kubectl get namespace ${MONITORING_NAMESPACE} >/dev/null 2>&1
then
    set_message "EdWMessage" "0" "Namespace -> ${MONITORING_NAMESPACE} existe déjà, on continue."
else
    kubectl create namespace ${MONITORING_NAMESPACE}
fi

#─────────────────────────────────────────────────────────────────────────────
# Vérification de la présence du namespace monitoring
#─────────────────────────────────────────────────────────────────────────────
set_message "check" "0" "Vérification de la liste des namespaces pour -> ${MONITORING_NAMESPACE}:"
kubectl get namespace ${MONITORING_NAMESPACE}

#─────────────────────────────────────────────────────────────────────────────
# Description du namespace monitoring
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Description du namespace -> ${MONITORING_NAMESPACE}:"
kubectl describe namespace ${MONITORING_NAMESPACE}

#─────────────────────────────────────────────────────────────────────────────
# Vérification du namespace par défaut
#─────────────────────────────────────────────────────────────────────────────
set_message "check" "0" "Vérification de l environnement namespace par défaut:"
kubectl config view --minify | grep namespace

#─────────────────────────────────────────────────────────────────────────────
# Liste des événements du namespace monitoring
#─────────────────────────────────────────────────────────────────────────────
set_message "debug" "0" "Liste de tous les évènements du namespace -> ${MONITORING_NAMESPACE}"
kubectl get events -n ${MONITORING_NAMESPACE}

#─────────────────────────────────────────────────────────────────────────────
# Suppression du namespace (optionnel)
#─────────────────────────────────────────────────────────────────────────────
# set_message "warn" "0" "Suppression du namespace monitoring"
# kubectl delete namespace ${MONITORING_NAMESPACE}

printf "\n"
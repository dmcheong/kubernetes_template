#!/usr/bin/env bash
#===============================================================================
# Fichier      : script_test_namespace_traefik.sh
# Description  : Test et gestion du namespace traefik en local
# Prérequis    : kubectl disponible, cluster actif (minikube ou autre)
#===============================================================================
global_configuration_file="${root_path}/config/global.env"
if [[ -f "${global_configuration_file}" ]]
  then
    . "${global_configuration_file}"
fi

set_message "info" "0" "Gestion du namespace ${TRAEFIK_NAMESPACE}."
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
# Création du namespace traefik (idempotent)
# Le namespace traefik est utilisé pour les tests liés à l'ingress controller
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Création d un environnement namespace -> ${TRAEFIK_NAMESPACE}:"
if kubectl get namespace ${TRAEFIK_NAMESPACE} >/dev/null 2>&1
then
    set_message "EdWMessage" "0" "Namespace -> ${TRAEFIK_NAMESPACE} existe déjà, on continue."
else
    kubectl create namespace ${TRAEFIK_NAMESPACE}
fi

#─────────────────────────────────────────────────────────────────────────────
# Vérification de la présence du namespace traefik
#─────────────────────────────────────────────────────────────────────────────
set_message "check" "0" "Vérification de la liste des namespaces pour -> ${TRAEFIK_NAMESPACE}:"
kubectl get namespaces ${TRAEFIK_NAMESPACE}

#─────────────────────────────────────────────────────────────────────────────
# Description du namespace traefik
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Description du namespace -> ${TRAEFIK_NAMESPACE}:"
kubectl describe namespace ${TRAEFIK_NAMESPACE}

#
#─────────────────────────────────────────────────────────────────────────────
# Vérification du namespace par défaut
#─────────────────────────────────────────────────────────────────────────────
set_message "check" "0" "Vérification de l environnement namespace par défaut:"
kubectl config view --minify | grep namespace

#─────────────────────────────────────────────────────────────────────────────
# Liste des événements du namespace traefik
#─────────────────────────────────────────────────────────────────────────────
set_message "debug" "0" "Liste de tous les évènements du namespace -> ${TRAEFIK_NAMESPACE}"
kubectl get events -n ${TRAEFIK_NAMESPACE}

#─────────────────────────────────────────────────────────────────────────────
# Suppression du namespace (optionnel)
#─────────────────────────────────────────────────────────────────────────────
# set_message "warn" "0" "Suppression du namespace ${TRAEFIK_NAMESPACE}"
# kubectl delete namespace ${TRAEFIK_NAMESPACE}

printf "\n"
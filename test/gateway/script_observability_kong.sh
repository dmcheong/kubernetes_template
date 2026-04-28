#!/usr/bin/env bash
#===============================================================================
# Fichier      : script_kong_gateway.sh
# Description  : Installe Kong Gateway avec PostgreSQL comme backend de données.
#                Kong joue le rôle d'ingress controller et d'API Gateway.
# Prérequis    : helm, kubectl, kubeseal installés — namespace kong absent ou vide
# Note         : ce script n'est pas dans le répertoire install/ par choix
#                pédagogique (séparation installation / test)
#===============================================================================
# chemins absolus pour être indépendant du répertoire courant
KONG_CONF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KONG_OBSER_FILE="${KONG_CONF_DIR}/kong-observability.yml"
KONG_ROUTE_FILE="${KONG_CONF_DIR}/kong-route-to-nginx.yml"
printf "%b\n" 

set_message "info" "0" "Application de l observabilité de kong"
kubectl apply -f ${KONG_OBSER_FILE}

set_message "info" "0" "Application des connexions de kong aux pods de test nginx"
kubectl apply -f ${KONG_ROUTE_FILE}
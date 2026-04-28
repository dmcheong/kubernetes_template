#!/usr/bin/env bash
#===============================================================================
# Fichier      : index.sh
# Description  : Point d'entrée principal — orchestre l'installation des outils
#                puis le déploiement complet du cluster de test Kubernetes.
# Usage        : bash index.sh
# Prérequis    : Docker Engine démarré, Minikube disponible
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
if [[ -f "${global_configuration_file}" ]] then
    . "${global_configuration_file}"
fi

if [[ ${core_functions_loaded} -ne 1 ]] then
    . "${root_path}/kubernetes_template/scripts/lib/core.sh"
fi

set_message "info" "0" "Bonjour, bienvenue dans sur le déploiment automatique d un environnement kubernetes."

#─────────────────────────────────────────────────────────────────────────────
# vérification et installation des outils de base
#   → Docker, Helm, kubectl, Minikube, asdf, kube-score, kubeseal
#─────────────────────────────────────────────────────────────────────────────
source ./scripts/bin/check_installation_basique_tools.sh

# démarrage du cluster Minikube (commenter en production)
# set_message "info" "0" "Démarrage de Minikube."
# minikube start
printf "%b\n"

#─────────────────────────────────────────────────────────────────────────────
# déploiement du cluster de test
#   Ordre important : namespaces → pods → deployments → services
#                    → storage → secrets
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Exécution global des scripts de déploiement du cluster:"
printf "%b\n"

# création des namespaces (dev, …)
# source ./test/namespaces/script_test_namespaces.sh

# déploiement de pods de test
# source ./test/pods/script_test_pods.sh

# déploiement d'applications (nginx, …)
# source ./test/deployment/script_test_deployment.sh

# exposition des applications via des Services
# source ./test/services/script_test_services.sh

# stockage persistant (PVC NFS)
# source ./test/storageclass/script_test_storageclass.sh

# gestion des secrets chiffrés (SealedSecrets)
# source ./test/sealed-secrets/script_sealed_secret.sh

#─────────────────────────────────────────────────────────────────────────────
# adaptation de l'ordre de déploiement : installation ==> configuration 
# Traefik -> OTel -> Kong
#─────────────────────────────────────────────────────────────────────────────

#─────────────────────────────────────────────────────────────────────────────
# reverse proxy — Traefik (installation)
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Exécution des scripts de l environnement du reverse-proxy:"

# namespace traefik
# source ./test/namespaces/script_test_namespaces_traefik.sh

# installation de Traefik via Helm
# source ./test/ingress/reverse_proxy/install_traefik.sh

#─────────────────────────────────────────────────────────────────────────────
# monitoring — Prometheus + Grafana + OpenTelemetry (installation)
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Exécution des scripts de l environnement de monitoring:"

# namespace monitoring
# source ./test/namespaces/script_test_namespaces_monitoring.sh

# installation de Prometheus + Grafana + OpenTelemetry
# source ./scripts/bin/check_installation_monitoring_tools.sh

#─────────────────────────────────────────────────────────────────────────────
# gateway — Kong Gateway (installation)
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Exécution des scripts de l environnement du gateway:"

# installation de la gateway Kong
# source ./test/gateway/script_kong_gateway.sh

#─────────────────────────────────────────────────────────────────────────────
# Configuration global
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Mise en place du reverse-proxy (TRAEFIK):"

# déploiement de l'application de test (whoami)
# source ./test/ingress/reverse_proxy/script_test_traefik_deploy.sh

set_message "info" "0" "Mise en place des services de monitoring:"

# observabilité kong
# source ./test/gateway/script_observability_kong.sh

#─────────────────────────────────────────────────────────────────────────────
# vault — Hashicorp
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Exécution des scripts de l environnement des vaults Hashicorp + AWS Secrets Manager:"

set_message "info" "0" "Mise en place du vault Hashicorp:"

# namespace hashicorp
# source ./test/namespaces/script_test_namespaces_hashicorp.sh

# installation du vault Hashicorp via helm
# source ./test/vault/hashicorp/install_vault_hashicorp.sh

# déploiement et configuration du vault
# source ./test/vault/hashicorp/script_test_vault_hashicorp.sh

#─────────────────────────────────────────────────────────────────────────────
# dashboard
#─────────────────────────────────────────────────────────────────────────────
set_message "infos" "0" ""

# source ./test/namespaces/script_test_namespaces_dashboard.sh

# source ./test/dashboard/kubernetes_dashboard.sh

#─────────────────────────────────────────────────────────────────────────────
# all port acces
#─────────────────────────────────────────────────────────────────────────────

#─────────────────────────────────────────────────────────────────────────────
# nettoyage (optionnelle)
#─────────────────────────────────────────────────────────────────────────────
printf "%b\n"
set_message "info" "0" "Fin global des scripts de déploiement."
printf "%b\n"

# Décommenter pour supprimer l ensemble des namespaces dev + monitoring + kong + traefik + ... après les tests
# set_message "info" "0" "Suppression de tous les environnements de test:"
# source ./scripts/bin/clean_env_dev.sh
# printf "%b\n"

# arrêt de Minikube (décommenter si nécessaire)
# set_message "info" "0" "Arrêt de Minikube."
# minikube stop
# printf "%b\n"

# suppression de l image minikube (décommenter si nécessaire)
# set_message "info" "0" "Suppression de l'image Minikube pour le test entier du script"
# minikube delete
# printf "%b\n"

set_message "EdSMessage" "0" "Fin du script d automatisation."

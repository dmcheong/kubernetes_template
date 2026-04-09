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
    . "${root_path}/lib/core.sh"
fi

set_message "info" "0" "Bonjour, bienvenue dans sur le déploiment automatique d un environnement kubernetes."

#─────────────────────────────────────────────────────────────────────────────
# Phase 1 : vérification et installation des outils de base
#   → Docker, Helm, kubectl, Minikube, asdf, kube-score, kubeseal
#─────────────────────────────────────────────────────────────────────────────
# source ./scripts/bin/check_installation_basique_tools.sh

# démarrage du cluster Minikube (commenter en production)
# set_message "info" "0" "Démarrage de Minikube."
# minikube start
# printf "%b\n"

#─────────────────────────────────────────────────────────────────────────────
# Phase 2 : déploiement du cluster de test
#   Ordre important : namespaces → pods → deployments → services
#                    → storage → secrets → gateway
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Exécution global des scripts de déploiement du cluster:"

# création des namespaces (dev, …)
source ./test/namespaces/script_test_namespaces.sh

# déploiement de pods de test
source ./test/pods/script_test_pods.sh

# déploiement d'applications (nginx, …)
source ./test/deployment/script_test_deployment.sh

# exposition des applications via des Services
source ./test/services/script_test_services.sh

# stockage persistant (PVC NFS)
source ./test/storageclass/script_test_storageclass.sh

# gestion des secrets chiffrés (SealedSecrets)
source ./test/sealed-secrets/script_sealed_secret.sh

# installation de la gateway Kong
source ./test/gateway/script_kong_gateway.sh

#─────────────────────────────────────────────────────────────────────────────
# Phase 3 : monitoring — Prometheus + Grafana + OpenTelemetry
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Exécution des scripts de l environnement de monitoring:"

set_message "info" "0" "Mise en place des services de monitoring:"

# namespace monitoring
source ./test/namespaces/script_test_namespaces_monitoring.sh

# installation de Prometheus + Grafana + OpenTelemetry
source ./scripts/bin/check_installation_monitoring_tools.sh

# services métriques (ServiceMonitor)
source ./test/services/script_test_services_monitoring.sh

#─────────────────────────────────────────────────────────────────────────────
# Phase 4 : reverse proxy — Traefik
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Exécution des scripts de l environnement du reverse-proxy:"

set_message "info" "0" "Mise en place du reverse-proxy (TRAEFIK):"

# namespace traefik
source ./test/namespaces/script_test_namespaces_traefik.sh

# installation de Traefik via Helm
source ./test/ingress/reverse_proxy/install_traefik.sh

# déploiement de l'application de test (whoami)
source ./test/ingress/reverse_proxy/script_test_traefik_deploy.sh

printf "%b\n"
set_message "info" "0" "Fin global des scripts de déploiement."
printf "%b\n"

#─────────────────────────────────────────────────────────────────────────────
# Phase 5 (optionnelle) : nettoyage
#─────────────────────────────────────────────────────────────────────────────
# Décommenter pour supprimer l ensemble des namespaces dev + monitoring + kong + traefik + ... après les tests
# set_message "info" "0" "Suppression de tous les environnements de test:"
# source ./scripts/bin/clean_env_dev.sh
# printf "%b\n"

# arrêt de Minikube (décommenter si nécessaire)
# set_message "info" "0" "Arrêt de Minikube."
# minikube stop
# printf "%b\n"

set_message "EdSMessage" "0" "Fin du script d automatisation."

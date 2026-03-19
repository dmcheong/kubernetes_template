#!/usr/bin/env bash
#===============================================================================
# Fichier      : index.sh
# Description  : Point d'entrée principal — orchestre l'installation des outils
#                puis le déploiement complet du cluster de test Kubernetes.
# Usage        : bash index.sh
# Prérequis    : Docker Engine démarré, Minikube disponible
#===============================================================================

# démarrage du cluster Minikube (décommenter en production)
echo "==> Démarrage de Minikube."
# minikube start
echo

#─────────────────────────────────────────────────────────────────────────────
# Phase 1 : vérification et installation des outils de base
#   → Docker, Helm, kubectl, Minikube, asdf, kube-score, kubeseal
#─────────────────────────────────────────────────────────────────────────────
source ./scripts/bin/check_installation_basique_tools.sh

#─────────────────────────────────────────────────────────────────────────────
# Phase 2 : déploiement du cluster de test
#   Ordre important : namespaces → pods → deployments → services
#                    → storage → secrets → gateway
#─────────────────────────────────────────────────────────────────────────────
echo "==> Exécution global des scripts de déploiement du cluster:"

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
echo "==> Exécution des scripts de l environnement de monitoring:"

# installation de Prometheus + Grafana + OpenTelemetry
source ./scripts/bin/check_installation_monitoring_tools.sh

echo "==> Mise en place des services de monitoring:"

# namespace monitoring
source ./test/namespaces/script_test_namespaces_monitoring.sh

# services métriques (ServiceMonitor)
source ./test/services/script_test_services_monitoring.sh

#─────────────────────────────────────────────────────────────────────────────
# Phase 4 : reverse proxy — Traefik
#─────────────────────────────────────────────────────────────────────────────
echo "==> Mise en place du reverse proxy:"

# namespace traefik
source ./test/namespaces/script_test_namespaces_traefik.sh

# installation de Traefik via Helm
source ./test/ingress/reverse_proxy/install_traefik.sh

# déploiement de l'application de test (whoami)
source ./test/ingress/reverse_proxy/script_test_traefik_deploy.sh

echo
echo "==> Fin global des scripts de déploiement."
echo

#─────────────────────────────────────────────────────────────────────────────
# Phase 5 (optionnelle) : nettoyage
#─────────────────────────────────────────────────────────────────────────────
# Décommenter pour supprimer les namespaces dev et monitoring après les tests
# echo "==> Suppression de tous les environnements de test:"
# source ./scripts/bin/clean_env_dev.sh
# echo

# arrêt de Minikube (décommenter si nécessaire)
# echo "==> Arrêt de Minikube."
# minikube stop
# echo

echo "==> Fin du script d automatisation."

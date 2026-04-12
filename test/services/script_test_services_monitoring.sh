#!/usr/bin/env bash
#===============================================================================
# Fichier      : script_test_services_monitoring.sh
# Description  : Déploie les services Kubernetes nécessaires au monitoring.
#                - service-kubernetes.yml : Service nginx avec port métriques 8080
#                - service-monitor.yml    : ServiceMonitor pour Prometheus
# Prérequis    : Prometheus (kube-prometheus-stack) déployé dans monitoring
#===============================================================================
set_message "info" "0" "Gestion des services de monitoring."
printf "%b\n"

# chemin absolu pour les templates
MONT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#─────────────────────────────────────────────────────────────────────────────
# Service nginx avec port métriques
# service-kubernetes.yml expose le port 8080 (métriques) de nginx
# Ce port est référencé par le ServiceMonitor ci-dessous
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Création du service kubernetes pour le monitoring:"
kubectl apply -f "$MONT_DIR/../template/service/service-kubernetes.yml"

#─────────────────────────────────────────────────────────────────────────────
# ServiceMonitor (CRD Prometheus Operator)
# service-monitor.yml indique à Prometheus de scraper le service demo-api
# sur le port http toutes les 15 secondes via /metrics
# Le label release: kube-prometheus-stack doit correspondre à la release Helm
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Création du service monitoring:"
kubectl apply -f "$MONT_DIR/../template/service/service-monitor.yml"

printf "%b\n"
#!/usr/bin/env bash
#===============================================================================
# Fichier      : script_test_prometheus_hscaling.sh
# Description  : Installe Prometheus Adapter et configure le HorizontalPodAutoscaler
#                pour scaler automatiquement un Deployment sur métriques custom.
# Prérequis    : Prometheus installé dans monitoring, namespace default disponible
# Flux :        Prometheus collecte http_requests_total
#               → Adapter expose la métrique dans l'API custom.metrics.k8s.io
#               → HPA lit la métrique et ajuste le nombre de réplicas
#===============================================================================

# chemin absolu pour les templates
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#─────────────────────────────────────────────────────────────────────────────
# Installation de Prometheus Adapter
# Le repo prometheus-community est déjà disponible (ajouté par install_prometheus.sh)
# adapter-values.yml configure :
#   - URL Prometheus : http://prometheus-operated.monitoring.svc:9090
#   - règle custom : http_requests_total → http_requests_per_second
#─────────────────────────────────────────────────────────────────────────────
echo "==> A cette étape, le repo helm devrait déjà être à jour sur le github: prometheus-community."
echo "==> Installation de l outil prometheus-adapter depuis le github: prometheus-community"
echo "==> installation dans le namespace monitoring en prenant en compte un fichier.yml spécifique pour la configuration."
helm install prometheus-adapter prometheus-community/prometheus-adapter \
  -n monitoring \
  -f "$SCRIPT_DIR/../../template/alerting/rules/adapter-values.yml"

#─────────────────────────────────────────────────────────────────────────────
# Vérification de l'API custom.metrics.k8s.io
# L'Adapter enregistre une extension d'API qui expose les métriques custom
# à Kubernetes (nécessaire pour que le HPA puisse les lire)
#─────────────────────────────────────────────────────────────────────────────
echo "==> Vérification des metrics spécifiques."
kubectl get apiservices | grep metrics
kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1 | jq

#─────────────────────────────────────────────────────────────────────────────
# Déploiement du HorizontalPodAutoscaler
# hpa.yml configure :
#   - cible : Deployment demo-api dans default
#   - min 2 réplicas, max 10 réplicas
#   - seuil : 20 requêtes/seconde par pod
#─────────────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Application des règles pour l autoscaling horizentale."
kubectl apply -f "$SCRIPT_DIR/../../template/alerting/rules/hpa.yml"

printf "%b\n"
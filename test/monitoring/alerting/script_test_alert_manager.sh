#!/usr/bin/env bash
#===============================================================================
# Fichier      : script_test_alert_manager.sh
# Description  : Met à jour Prometheus avec la configuration AlertManager
#                (webhook) et vérifie son déploiement dans le namespace monitoring.
# Prérequis    : Prometheus déjà installé via install_prometheus.sh
#===============================================================================

#─────────────────────────────────────────────────────────────────────────────
# Mise à jour de Prometheus avec la configuration AlertManager
# Le fichier alert-manager.yml active AlertManager avec :
#   - persistance activée (2Gi)
#   - route par défaut groupant par alertname + severity
#   - webhook vers https://webhook.site/VOTRE-UUID (à personnaliser)
#─────────────────────────────────────────────────────────────────────────────
echo "==> Mise à jour de prometheus avec la configuration d alert-manager dans le namespace monitoring."
helm upgrade prometheus prometheus-community/prometheus \
  -n monitoring \
  -f ./../../template/rules/helm-values/alert-manager.yml \
  --wait

#─────────────────────────────────────────────────────────────────────────────
# Vérification du pod AlertManager
#─────────────────────────────────────────────────────────────────────────────
echo "==> Vérification des pods dans le namespace monitoring"
kubectl get pods -n monitoring | grep alertmanager

echo "==> Vérification des services dans le namespace monitoring."
kubectl get services -n monitoring

#─────────────────────────────────────────────────────────────────────────────
# Accès au tableau de bord AlertManager
# AlertManager reçoit les alertes de Prometheus et les route vers les récepteurs
#─────────────────────────────────────────────────────────────────────────────
echo "==> Pour ouvrir le tableau de bord pour prometheux-alertmanager:"
kubectl port-forward svc/prometheus-alertmanager 9093:9093 -n monitoring
# puis ouvrir http://localhost:9093

printf "%b\n"
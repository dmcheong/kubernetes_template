#!/usr/bin/env bash

# This script checks or installs OpenTelemetry Collector with Helm and kubectl
# OpenTelemetry Collector chart requires mode=daemonset|deployment|statefulset

NAMESPACE="monitoring"
REPO_NAME="open-telemetry"
REPO_URL="https://open-telemetry.github.io/opentelemetry-helm-charts"
RELEASE="opentelemetry-collector"
CHART="${REPO_NAME}/opentelemetry-collector"

# Optional values file
# Example:
# SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# VALUES_FILE="$SCRIPT_DIR/../../test/template/monitoring/opentelemetry-values.yml"

echo "==> Exécution du script d'installation OpenTelemetry Collector."

# create monitoring namespace
echo "==> Namespace cible: $NAMESPACE"
if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
  echo "==> Création du namespace: $NAMESPACE"
  kubectl create namespace "$NAMESPACE" >/dev/null
else
  echo "==> Le namespace [$NAMESPACE] est déjà présent."
fi

# add OpenTelemetry repo in Helm repository list
if ! helm repo list 2>/dev/null | awk 'NR>1 {print $1}' | grep -qx "$REPO_NAME"; then
  echo "==> Ajout dans la liste des repositories Helm: $REPO_NAME"
  helm repo add "$REPO_NAME" "$REPO_URL" >/dev/null
else
  echo "==> Le repository Helm [$REPO_NAME] est déjà présent dans la liste."
fi

# update helm repository
echo "==> Mise à jour de l ensemble des repositories Helm."
helm repo update >/dev/null

# Install/upgrade
if helm status "$RELEASE" -n "$NAMESPACE" >/dev/null 2>&1; then
  echo "==> Release [$RELEASE] déjà installée -> upgrade (idempotent)"
else
  echo "==> Release [$RELEASE] absente -> installation"
fi

# if a specific values.yml exists, use it
if [ -n "${VALUES_FILE:-}" ] && [ -f "${VALUES_FILE}" ]; then
  echo "==> Déploiement via Helm avec fichier de configuration: $VALUES_FILE"
  helm upgrade --install "$RELEASE" "$CHART" \
    -n "$NAMESPACE" \
    -f "$VALUES_FILE" \
    --wait
else
  echo "==> Déploiement via Helm avec configuration minimale par défaut (mode=deployment)."
  helm upgrade --install "$RELEASE" "$CHART" \
    -n "$NAMESPACE" \
    --set mode=deployment \
    --wait
fi

echo
echo "==> Liste des pods OpenTelemetry dans [$NAMESPACE]:"
kubectl get pods -n "$NAMESPACE" | grep -E 'opentelemetry|otel|collector' || true

echo
echo "==> Liste des services OpenTelemetry dans [$NAMESPACE]:"
kubectl get svc -n "$NAMESPACE" | grep -E 'opentelemetry|otel|collector' || true

echo
echo "==> Commandes utiles :"
echo "kubectl get pods -n $NAMESPACE"
echo "kubectl logs -n $NAMESPACE -l app.kubernetes.io/name=opentelemetry-collector --tail=50"
echo

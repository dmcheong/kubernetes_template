#!/usr/bin/env bash

NAMESPACE="monitoring"
REPO_NAME="prometheus-community"
REPO_URL="https://prometheus-community.github.io/helm-charts"
RELEASE="kube-prometheus-stack"
CHART="${REPO_NAME}/kube-prometheus-stack"

# get abolute path
# SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Optionnel: fichier values pour personnaliser (NodePort, retention, storage, etc.)
# Mets-le à vide si tu n'en as pas.
# VALUES_FILE="$SCRIPT_DIR/../../test/template/.yml"

log() { printf "==> %s\n" "$*"; }
die() { printf "ERREUR: %s\n" "$*" >&2; exit 1; }

command -v kubectl >/dev/null 2>&1 || die "kubectl introuvable"
command -v helm   >/dev/null 2>&1 || die "helm introuvable"

log "Namespace cible: $NAMESPACE"
if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
  log "Création du namespace $NAMESPACE"
  kubectl create namespace "$NAMESPACE" >/dev/null
else
  log "Namespace $NAMESPACE déjà présent"
fi

# Repo Helm
if ! helm repo list 2>/dev/null | awk 'NR>1 {print $1}' | grep -qx "$REPO_NAME"; then
  log "Ajout du repo Helm $REPO_NAME"
  helm repo add "$REPO_NAME" "$REPO_URL" >/dev/null
else
  log "Repo Helm $REPO_NAME déjà présent"
fi

log "Mise à jour des repos Helm"
helm repo update >/dev/null

# Install/upgrade
if helm status "$RELEASE" -n "$NAMESPACE" >/dev/null 2>&1; then
  log "Release '$RELEASE' déjà installée -> upgrade (idempotent)"
else
  log "Release '$RELEASE' absente -> installation"
fi

if [ -f "$VALUES_FILE" ]; then
  log "Déploiement via Helm + values: $VALUES_FILE"
  helm upgrade --install "$RELEASE" "$CHART" -n "$NAMESPACE" -f "$VALUES_FILE" --wait
else
  log "Déploiement via Helm (values par défaut)"
  helm upgrade --install "$RELEASE" "$CHART" -n "$NAMESPACE" --wait
fi

echo
log "Pods principaux dans $NAMESPACE :"
kubectl get pods -n "$NAMESPACE" | grep -E 'prometheus|alertmanager|grafana|operator|node-exporter|kube-state-metrics' || true

echo
log "Accès rapides :"
echo "Prometheus (port-forward): kubectl -n $NAMESPACE port-forward svc/${RELEASE}-prometheus 9090:9090"
echo "Grafana (port-forward):    kubectl -n $NAMESPACE port-forward svc/${RELEASE}-grafana 3000:80"
echo
echo "Grafana admin password (secret):"
kubectl -n "$NAMESPACE" get secret "${RELEASE}-grafana" -o jsonpath="{.data.admin-password}" 2>/dev/null | base64 -d && echo || true
echo
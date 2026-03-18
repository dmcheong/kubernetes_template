#!/usr/bin/env bash

# This script check or update last version of Prometheus and Grafana
# Install with helm adn kubectl
# prometheus community github already add Grafana-stack with (check: kubectl get services)

NAMESPACE="monitoring"
REPO_NAME="prometheus-community"
REPO_URL="https://prometheus-community.github.io/helm-charts"
RELEASE="kube-prometheus-stack"
CHART="${REPO_NAME}/kube-prometheus-stack"

# get abolute path
# SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Optionnal: can set specifique configuration with values.yml (NodePort, retention, storage, etc.)
# if none dont put any values.yml
# VALUES_FILE="$SCRIPT_DIR/../../test/template/monitoring/prometheus-minimal.yml" or prometheus-values.yml they are not use in this project

echo "==> Exécution du script d'installation des outils de monitoring [Prometheus + Grafana]."

# create monitoring namespace
echo "==> Namespace cible: $NAMESPACE"
if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
  echo "==> Création du namespace: $NAMESPACE"
  kubectl create namespace "$NAMESPACE" >/dev/null
else
  echo "==> Le namespace [$NAMESPACE] est déjà présent."
fi

# add prometheus in helm repository
if ! helm repo list 2>/dev/null | awk 'NR>1 {print $1}' | grep -qx "$REPO_NAME"; then
  echo "==> Ajout dans la liste des repositories helm, le repository suivant: $REPO_NAME"
  helm repo add "$REPO_NAME" "$REPO_URL" >/dev/null
else
  echo "==> Le repository Helm [$REPO_NAME] est déjà présent dans la liste."
fi

# update helm repository
echo "==> Mise à jour de l ensemble des repository Helm."
helm repo update >/dev/null

# Install/upgrade
if helm status "$RELEASE" -n "$NAMESPACE" >/dev/null 2>&1; then
  echo "==> Release [$RELEASE] déjà installée -> upgrade (idempotent)"
else
  echo "==> Release [$RELEASE] absente -> installation"
fi

# if specific values.yml for prometheus exists, set them
if [ -f "$VALUES_FILE" ]; then
  echo "==> Déploiement via Helm de valeurs spécifiques via le fichier de configuration: $VALUES_FILE"
  helm upgrade --install "$RELEASE" "$CHART" -n "$NAMESPACE" -f "$VALUES_FILE" --wait
else
  echo "==> Déploiement via Helm des valeurs par défaut."
  helm upgrade --install "$RELEASE" "$CHART" -n "$NAMESPACE" --wait
fi

# echo to check pods, services and Grafana dashboard secret password
echo
echo "==> Liste des Pods principaux dans [$NAMESPACE]:"
kubectl get pods -n "$NAMESPACE" | grep -E 'prometheus|alertmanager|grafana|operator|node-exporter|kube-state-metrics' || true
echo
echo "==> Listes des services et stack dans le namespace" "$NAMESPACE"
kubectl get services -n $NAMESPACE
echo
echo "==> Pour accéder rapidement au tableau de bords dans un navigateur lancer les commandes suivantes:"
echo "Prometheus (port-forward): kubectl -n $NAMESPACE port-forward svc/${RELEASE}-prometheus 9090:9090"
echo "Grafana (port-forward):    kubectl -n $NAMESPACE port-forward svc/${RELEASE}-grafana 3000:80"
echo
echo "ATTENTION: ne pas laisser cette logique d'exposition des secrets dans le code d automatisation pour l environnement de production."
echo "Grafana admin password (modifier le mot de passe dès la première connexion):"
kubectl -n "$NAMESPACE" get secret "${RELEASE}-grafana" -o jsonpath="{.data.admin-password}" 2>/dev/null | base64 -d && echo || true
echo

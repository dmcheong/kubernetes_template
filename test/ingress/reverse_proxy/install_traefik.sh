#!usr/bin/env bash
# This script set a reverse proxy ingress controller with traeffik
# This script is not with install repertory for understanding 

NAMESPACE="traefik"
REPO_NAME="traefik"
REPO_URL="https://traefik.github.io/charts"
RELEASE="traefik"
CHART="${REPO_NAME}/traefik"

# SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# VALUES_FILE="$SCRIPT_DIR/traefik.yml"

echo "==> Exécution du script d'installation de Traefik."

echo "==> Namespace cible: $NAMESPACE"
if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
  echo "==> Création du namespace: $NAMESPACE"
  kubectl create namespace "$NAMESPACE" >/dev/null
else
  echo "==> Le namespace [$NAMESPACE] est déjà présent."
fi

if ! helm repo list 2>/dev/null | awk 'NR>1 {print $1}' | grep -qx "$REPO_NAME"; then
  echo "==> Ajout du repository Helm: $REPO_NAME"
  helm repo add "$REPO_NAME" "$REPO_URL" >/dev/null
else
  echo "==> Le repository Helm [$REPO_NAME] est déjà présent."
fi

echo "==> Mise à jour des repositories Helm."
helm repo update >/dev/null

if helm status "$RELEASE" -n "$NAMESPACE" >/dev/null 2>&1; then
  echo "==> Release [$RELEASE] déjà installée -> upgrade"
else
  echo "==> Release [$RELEASE] absente -> installation"
fi

echo "==> Déploiement de Traefik avec le fichier: $VALUES_FILE"
helm upgrade --install "$RELEASE" "$CHART" \
  -n "$NAMESPACE" \
  -f "$VALUES_FILE" \
  --wait

echo
echo "==> Pods Traefik"
kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/name=traefik || true

echo
echo "==> Services Traefik"
kubectl get svc -n "$NAMESPACE" || true

echo
echo "==> ServiceMonitor Traefik"
kubectl get servicemonitor -A | grep traefik || true

echo
echo "==> Accès utiles"
echo "Dashboard Traefik: kubectl -n $NAMESPACE port-forward svc/$RELEASE 9000:9000"
echo "Service Minikube:  minikube service $RELEASE -n $NAMESPACE --url"
echo
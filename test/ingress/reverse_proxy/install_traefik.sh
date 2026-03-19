#!/usr/bin/env bash
#===============================================================================
# Fichier      : install_traefik.sh
# Description  : Installe Traefik comme ingress controller via Helm.
#                Configure les métriques Prometheus et les traces OpenTelemetry.
# Prérequis    : helm, kubectl installés — Prometheus + OTel Collector déployés
# Note         : ce script n'est pas dans scripts/bin/ par choix pédagogique
#===============================================================================

# paramètres Helm
NAMESPACE="traefik"       # namespace cible pour Traefik
REPO_NAME="traefik"       # nom du repo Helm Traefik
REPO_URL="https://traefik.github.io/charts"
RELEASE="traefik"         # nom de la release Helm
CHART="${REPO_NAME}/traefik"

echo "==> Exécution du script d'installation de Traefik."

#─────────────────────────────────────────────────────────────────────────────
# Namespace traefik (idempotent)
#─────────────────────────────────────────────────────────────────────────────
echo "==> Namespace cible: $NAMESPACE"
if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
  echo "==> Création du namespace: $NAMESPACE"
  kubectl create namespace "$NAMESPACE" >/dev/null
else
  echo "==> Le namespace [$NAMESPACE] est déjà présent."
fi

#─────────────────────────────────────────────────────────────────────────────
# Ajout du repo Helm Traefik (idempotent)
#─────────────────────────────────────────────────────────────────────────────
if ! helm repo list 2>/dev/null | awk 'NR>1 {print $1}' | grep -qx "$REPO_NAME"; then
  echo "==> Ajout du repository Helm: $REPO_NAME"
  helm repo add "$REPO_NAME" "$REPO_URL" >/dev/null
else
  echo "==> Le repository Helm [$REPO_NAME] est déjà présent."
fi

echo "==> Mise à jour des repositories Helm."
helm repo update >/dev/null

#─────────────────────────────────────────────────────────────────────────────
# Installation / upgrade Traefik (idempotent via helm upgrade --install)
# Le fichier traefik.yml configure :
#   - ports 80/443 (web/websecure) → LoadBalancer
#   - port 9000 (dashboard, non exposé)
#   - port 9100 (métriques Prometheus)
#   - export OTLP vers opentelemetry-collector.monitoring.svc.cluster.local
#   - ServiceMonitor pour découverte automatique par kube-prometheus-stack
#─────────────────────────────────────────────────────────────────────────────
if helm status "$RELEASE" -n "$NAMESPACE" >/dev/null 2>&1; then
  echo "==> Release [$RELEASE] déjà installée -> upgrade"
else
  echo "==> Release [$RELEASE] absente -> installation"
fi

# déploiement avec le fichier de valeurs traefik.yml
echo "==> Déploiement de Traefik avec le fichier: $VALUES_FILE"
helm upgrade --install "$RELEASE" "$CHART" \
  -n "$NAMESPACE" \
  -f "$VALUES_FILE" \
  --wait

#─────────────────────────────────────────────────────────────────────────────
# Vérification post-installation
#─────────────────────────────────────────────────────────────────────────────
echo
echo "==> Pods Traefik"
kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/name=traefik || true

echo
echo "==> Services Traefik"
kubectl get svc -n "$NAMESPACE" || true

echo
echo "==> ServiceMonitor Traefik (intégration Prometheus)"
kubectl get servicemonitor -A | grep traefik || true

# accès utiles pour les développeurs
echo
echo "==> Accès utiles"
echo "Dashboard Traefik: kubectl -n $NAMESPACE port-forward svc/$RELEASE 9000:9000"
echo "puis: http://localhost:9000/dashboard/"

#!/usr/bin/env bash
# the version of choosen prometheus as already grafana
# this script check if grafana is installed

# This script check or update last version (set in the script) of Grafana
# Install helm

NAMESPACE="monitoring"
STACK_RELEASE="kube-prometheus-stack"
GRAFANA_SVC="${STACK_RELEASE}-grafana"

log() { printf "==> %s\n" "$*"; }
die() { printf "ERREUR: %s\n" "$*" >&2; exit 1; }

command -v kubectl >/dev/null 2>&1 || die "kubectl introuvable"
command -v helm   >/dev/null 2>&1 || die "helm introuvable"

log "Vérification Grafana (via kube-prometheus-stack)"

# 1) Vérifier que la release existe
if ! helm status "$STACK_RELEASE" -n "$NAMESPACE" >/dev/null 2>&1; then
  die "La release '$STACK_RELEASE' n'est pas installée dans '$NAMESPACE'. Installe kube-prometheus-stack d'abord."
fi

# 2) Vérifier que le service Grafana existe
if ! kubectl get svc -n "$NAMESPACE" "$GRAFANA_SVC" >/dev/null 2>&1; then
  die "Service Grafana introuvable: $NAMESPACE/$GRAFANA_SVC"
fi

# 3) Vérifier pods Grafana
log "Pods Grafana:"
kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/name=grafana || true
echo

# 4) Récupérer le password admin (secret Helm du stack)
log "Password admin Grafana (secret):"
kubectl -n "$NAMESPACE" get secret "$GRAFANA_SVC" \
  -o jsonpath="{.data.admin-password}" 2>/dev/null | base64 -d && echo || true
echo
log "User admin: admin"
echo

# 5) Accès
log "Accès Grafana :"
echo "1) Minikube:      minikube service $GRAFANA_SVC -n $NAMESPACE --url"
echo "2) Port-forward:  kubectl port-forward -n $NAMESPACE svc/$GRAFANA_SVC 3000:80"
echo
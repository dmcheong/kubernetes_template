#!/usr/bin/env bash
#===============================================================================
# Fichier      : install_traefik.sh
# Description  : Installe Traefik comme ingress controller via Helm.
#                Configure les métriques Prometheus et les traces OpenTelemetry.
# Prérequis    : helm, kubectl installés — Prometheus + OTel Collector déployés
# Note         : ce script n'est pas dans scripts/bin/ par choix pédagogique
#===============================================================================
TRAEF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRAEF_VALUES_FILE="$TRAEF_DIR/traefik.yml"

global_configuration_file="${root_path}/config/global.env"
if [[ -f "${global_configuration_file}" ]]
  then
    . "${global_configuration_file}"
fi

set_message "info" "0" "Exécution du script d installation de ${TRAEFIK_NAMESPACE}."

#─────────────────────────────────────────────────────────────────────────────
# Namespace traefik (idempotent)
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Namespace cible: ${TRAEFIK_NAMESPACE}"
if ! kubectl get namespace "${TRAEFIK_NAMESPACE}" >/dev/null 2>&1; then
  set_message "info" "0" "Création du namespace: ${TRAEFIK_NAMESPACE}"
  kubectl create namespace "${TRAEFIK_NAMESPACE}" >/dev/null
else
  set_message "EdWMessage" "0" "Le namespace [${TRAEFIK_NAMESPACE}] est déjà présent."
fi

#─────────────────────────────────────────────────────────────────────────────
# Ajout du repo Helm Traefik (idempotent)
#─────────────────────────────────────────────────────────────────────────────
if ! helm repo list 2>/dev/null | awk 'NR>1 {print $1}' | grep -qx "${TRAEFIK_REPO_NAME}"; then
  set_message "info" "0" "Ajout du repository Helm: ${TRAEFIK_REPO_NAME}"
  helm repo add "${TRAEFIK_REPO_NAME}" "${TRAEFIK_REPO_URL}" >/dev/null
else
  set_message "EdWMessage" "0" "Le repository Helm [${TRAEFIK_REPO_NAME}] est déjà présent."
fi

set_message "info" "0" "Mise à jour des repositories Helm."
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
if helm status "${TRAEFIK_RELEASE}" -n "${TRAEFIK_NAMESPACE}" >/dev/null 2>&1; then
  set_message "EdWMessage" "0" "Release [${TRAEFIK_RELEASE}] déjà installée -> upgrade"
else
  set_message "EdWMessage" "0" "Release [${TRAEFIK_RELEASE}] absente -> installation"
fi

# déploiement avec le fichier de valeurs traefik.yml
set_message "info" "0" "Déploiement de Traefik avec le fichier: ${TRAEF_VALUES_FILE}"
helm upgrade --install "${TRAEFIK_RELEASE}" "${TRAEFIK_CHART}" -n "${TRAEFIK_NAMESPACE}" -f "${TRAEF_VALUES_FILE}"

#─────────────────────────────────────────────────────────────────────────────
# Vérification post-installation
#─────────────────────────────────────────────────────────────────────────────
printf "%b\n"
set_message "check" "0" "Liste des pods Traefik"
kubectl get pods -n "${TRAEFIK_NAMESPACE}" -l app.kubernetes.io/name=traefik || true

printf "%b\n"
set_message "check" "0" "Liste des services Traefik"
kubectl get svc -n "${TRAEFIK_NAMESPACE}" || true

printf "%b\n"
set_message "check" "0" "ServiceMonitor Traefik (intégration Prometheus)"
kubectl get servicemonitor -A | grep traefik || true

# accès utiles pour les développeurs
printf "%b\n"
echo "==> Accès utiles:"
echo "Dashboard Traefik: kubectl -n ${TRAEFIK_NAMESPACE} port-forward svc/${TRAEFIK_RELEASE} 9000:9000"
echo "puis: http://localhost:9000/dashboard/"
echo "Service Minikube:  minikube service ${TRAEFIK_RELEASE} -n ${TRAEFIK_NAMESPACE} --url"
printf "%b\n"

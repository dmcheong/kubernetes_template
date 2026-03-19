#!/usr/bin/env bash
#===============================================================================
# Fichier      : script_test_traefik_deploy.sh
# Description  : Déploie l'application de test "whoami" dans le namespace dev
#                et crée une IngressRoute Traefik pour l'exposer sur whoami.local.
# Prérequis    : Traefik installé (install_traefik.sh), namespace dev créé
#===============================================================================

# chemins absolus pour être indépendant du répertoire courant
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_FILE="$SCRIPT_DIR/whoami.yml"          # Deployment + Service whoami dans dev
ROUTE_FILE="$SCRIPT_DIR/whoami-ingressroute.yml"  # IngressRoute CRD Traefik

echo "==> Déploiement de l'application de test de traefik pour l environnement pour le namespace dev"

#─────────────────────────────────────────────────────────────────────────────
# Déploiement de l'application whoami et de son IngressRoute
# whoami.yml crée :
#   - Namespace dev (idempotent)
#   - Deployment whoami (image traefik/whoami) avec annotations Prometheus
#   - Service whoami (ClusterIP port 80)
# whoami-ingressroute.yml crée :
#   - IngressRoute CRD Traefik → route Host(`whoami.local`) vers le Service whoami
#─────────────────────────────────────────────────────────────────────────────
kubectl apply -f "$APP_FILE"
kubectl apply -f "$ROUTE_FILE"

#─────────────────────────────────────────────────────────────────────────────
# Vérification des ressources déployées dans dev
#─────────────────────────────────────────────────────────────────────────────
echo
echo "==> Vérification de l environnement namespace: dev"
kubectl get pods -n dev
kubectl get svc -n dev
kubectl get ingressroute -n dev

#─────────────────────────────────────────────────────────────────────────────
# Instructions de test manuel
#─────────────────────────────────────────────────────────────────────────────
echo
echo "==> Test conseillé à effectuer via les commandes"
echo "1) Récupérer l'URL Traefik:"
echo "   minikube service traefik -n traefik --url"
echo
echo "2) Ajouter whoami.local dans /etc/hosts vers l'IP minikube"
echo "   echo \"\$(minikube ip) whoami.local\" | sudo tee -a /etc/hosts"
echo
echo "3) Tester:"
echo "   curl -H 'Host: whoami.local' http://<IP_OU_URL_TRAEFIK>"
echo

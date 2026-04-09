#!/usr/bin/env bash
#===============================================================================
# Fichier      : script_test_traefik_deploy.sh
# Description  : Déploie l'application de test "whoami" dans le namespace traefik
#                et crée une IngressRoute Traefik pour l'exposer sur whoami.local.
# Prérequis    : Traefik installé (install_traefik.sh), namespace traefik créé
#===============================================================================
# chemins absolus pour être indépendant du répertoire courant
TRAEF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_FILE="$TRAEF_DIR/whoami.yml"          # Deployment + Service whoami dans traefik
ROUTE_FILE="$TRAEF_DIR/whoami-ingressroute.yml"  # IngressRoute CRD Traefik

#─────────────────────────────────────────────────────────────────────────────
# Déploiement de l'application whoami et de son IngressRoute
# whoami.yml crée :
#   - Namespace traefik (idempotent)
#   - Deployment whoami (image traefik/whoami) avec annotations Prometheus
#   - Service whoami (ClusterIP port 80)
# whoami-ingressroute.yml crée :
#   - IngressRoute CRD Traefik → route Host(`whoami.local`) vers le Service whoami
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Déploiement de l'application de test de traefik pour le namespace traefik"
kubectl apply -f "$APP_FILE" -n traefik
kubectl apply -f "$ROUTE_FILE" -n traefik

#─────────────────────────────────────────────────────────────────────────────
# Vérification des ressources déployées dans traefik
#─────────────────────────────────────────────────────────────────────────────
printf "%b\n"
set_message "check" "0" "Vérification de l environnement namespace: traefik"
printf "%b\n"
set_message "check" "0" "Liste des pods dans le namespace -> treafik"
kubectl get pods -n traefik

set_message "check" "0" "Liste des services dans le namespace -> treafik"
kubectl get svc -n traefik

set_message "check" "0" "Liste des ingressroute dns le namespace -> traefik"
kubectl get ingressroute -n traefik

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

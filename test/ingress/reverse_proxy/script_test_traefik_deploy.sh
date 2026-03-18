#!usr/bin/env bash
# script testing traefik deployment in local
# use namespace dev

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_FILE="$SCRIPT_DIR/whoami.yml"
ROUTE_FILE="$SCRIPT_DIR/whoami-ingressroute.yml"

echo "==> Déploiement de l'application de test de traefik pour l environnement pour le namespace dev"
# [ -f "$APP_FILE" ] || { echo "ERREUR: fichier introuvable: $APP_FILE"; exit 1; }
# [ -f "$ROUTE_FILE" ] || { echo "ERREUR: fichier introuvable: $ROUTE_FILE"; exit 1; }

kubectl apply -f "$APP_FILE"
kubectl apply -f "$ROUTE_FILE"

echo
echo "==> Vérification de l environnement namespace: dev"
kubectl get pods -n dev
kubectl get svc -n dev
kubectl get ingressroute -n dev

echo
echo "==> Test conseillé à effectuer via les commandes"
echo "1) Récupérer l'URL Traefik:"
echo "   minikube service traefik -n traefik --url"
echo
echo "2) Ajouter whoami.local dans /etc/hosts vers l'IP minikube"
echo
echo "3) Tester:"
echo "   curl -H 'Host: whoami.local' http://<IP_OU_URL_TRAEFIK>"
echo
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

global_configuration_file="${root_path}/config/global.env"
if [[ -f "${global_configuration_file}" ]]
  then
    . "${global_configuration_file}"
fi

#─────────────────────────────────────────────────────────────────────────────
# Déploiement de l'application whoami et de son IngressRoute
# whoami.yml crée :
#   - Namespace traefik (idempotent)
#   - Deployment whoami (image traefik/whoami) avec annotations Prometheus
#   - Service whoami (ClusterIP port 80)
# whoami-ingressroute.yml crée :
#   - IngressRoute CRD Traefik → route Host(`whoami.local`) vers le Service whoami
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Déploiement de l'application de test de traefik pour le namespace ${TRAEFIK_NAMESPACE}"

[ -f "$APP_FILE" ] || { echo "ERREUR: fichier introuvable: $APP_FILE"; exit 1; }
[ -f "$ROUTE_FILE" ] || { echo "ERREUR: fichier introuvable: $ROUTE_FILE"; exit 1; }

kubectl apply -f "${APP_FILE}"
kubectl apply -f "${ROUTE_FILE}"

#─────────────────────────────────────────────────────────────────────────────
# Vérification des ressources déployées dans traefik
#─────────────────────────────────────────────────────────────────────────────
printf "%b\n"
set_message "check" "0" "Vérification des resouces relié à traefik dans l environnement namespace: dev"
printf "%b\n"
set_message "check" "0" "Vérification du pod whoami connecté à traefik dans le namespace -> dev"
kubectl get pods -n dev | grep whoami

set_message "check" "0" "Vérification du service whoami connecté à traefik dans le namespace -> dev"
kubectl get svc -n dev | grep whoami

set_message "check" "0" "Vérification de l ingressroute whoami connecté à traefik dans le namespace -> dev"
kubectl get ingressroute -n dev | grep whoami

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

printf "%b\n"
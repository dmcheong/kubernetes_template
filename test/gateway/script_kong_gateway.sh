#!/usr/bin/env bash
#===============================================================================
# Fichier      : script_kong_gateway.sh
# Description  : Installe Kong Gateway avec PostgreSQL comme backend de données.
#                Kong joue le rôle d'ingress controller et d'API Gateway.
# Prérequis    : helm, kubectl, kubeseal installés — namespace kong absent ou vide
# Note         : ce script n'est pas dans le répertoire install/ par choix
#                pédagogique (séparation installation / test)
#===============================================================================
# chemins absolus pour être indépendant du répertoire courant
GATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KONG_GATE_SECRET_FILE="$GATE_DIR/kong-gateway-secret.yaml"
KONG_GATE_SS_FILE="$GATE_DIR/kong-gateway-sealed-secret.yaml"
POST_VAL_FILE="$GATE_DIR/postgres-values.yml"
KONG_VAL_FILE="$GATE_DIR/kong-values.yml"

global_configuration_file="${root_path}/config/global.env"
if [[ -f "${global_configuration_file}" ]]
  then
    . "${global_configuration_file}"
fi

set_message "info" "0" "Gestion de la gateway avec Kong-Gateway."
printf "%b\n"

#─────────────────────────────────────────────────────────────────────────────
# Fonction utilitaire : ajouter un repo Helm s'il n'existe pas encore
# Usage : add_repo_if_missing <nom> <url>
#─────────────────────────────────────────────────────────────────────────────
set_message "check" "0" "Vérification du repo helm déjà téléchargée:"
add_repo_if_missing() {
  local name=$1
  local url=$2
  if ! helm repo list | awk '{print $1}' | grep -qx "$name"; then
    set_message "info" "0" "Ajout du repo $name"
    helm repo add "$name" "$url"
    error_CTRL "${?}" "Operation completed"
  else
    set_message "warn" "0" "Repo $name déjà présent"
  fi
}

# ajout des repos bitnami (PostgreSQL) et kong (Kong Gateway)
add_repo_if_missing ${BITNAMI_RELEASE} ${BITNAMI_REPO_URL}
add_repo_if_missing ${KONG_RELEASE} ${KONG_REPO_URL}
helm repo update >/dev/null 2>&1
error_CTRL "${?}" "Operation completed"

#─────────────────────────────────────────────────────────────────────────────
# Namespace kong
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Création du namespace ${KONG_NAMESPACE} pour kong gateway:"
if kubectl get namespace ${KONG_NAMESPACE} >/dev/null 2>&1
then
    set_message "EdWMessage" "0" "Namespace -> ${KONG_NAMESPACE} existe déjà, on continue."
else
    kubectl create namespace ${KONG_NAMESPACE}
    error_CTRL "${?}" "Operation completed"
fi
#─────────────────────────────────────────────────────────────────────────────
# Secret PostgreSQL (en clair — dev uniquement)
# En production : utiliser SealedSecrets (voir ci-dessous)
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Création d un secret pour postgresql"
set_message "warn" "0" "Ne pas mettre la gestion des secrets en production via le code (ici exemple):"

# application du secret en clair (à NE PAS pousser en production)
kubectl apply -f ${KONG_GATE_SECRET_FILE}
error_CTRL "${?}" "Operation completed"

#─────────────────────────────────────────────────────────────────────────────
# Chiffrement du secret avec kubeseal
# Le controller SealedSecrets doit être déployé dans kube-system
# La clé publique est récupérée automatiquement depuis le controller
#─────────────────────────────────────────────────────────────────────────────
# chiffrement → génère kong-gateway-sealed-secret.yaml (commitablesûrement)
kubeseal --controller-name=sealed-secrets-controller --controller-namespace=kube-system --format=yaml < ${KONG_GATE_SECRET_FILE} > ${KONG_GATE_SS_FILE}
error_CTRL "${?}" "Operation completed"

# déploiement du secret chiffré (le controller le déchiffre en Secret standard)
kubectl apply -f ${KONG_GATE_SS_FILE}
error_CTRL "${?}" "Operation completed"

#─────────────────────────────────────────────────────────────────────────────
# Configuration Docker locale sans modifier l'environnement système
# Nécessaire pour Helm + images privées dans certains environnements
#─────────────────────────────────────────────────────────────────────────────
mkdir -p ~/.docker-helm
error_CTRL "${?}" "Operation completed"
printf '{ "auths": {} }\n' > ~/.docker-helm/config.json

#─────────────────────────────────────────────────────────────────────────────
#─────────────────────────────────────────────────────────────────────────────
export POSTGRES_PASSWORD=$(kubectl get secret kong-ingress-controller-postgresql -n ${KONG_NAMESPACE} -o jsonpath="{.data.postgresql-password}" | base64 -d)
error_CTRL "${?}" "Operation completed"

#─────────────────────────────────────────────────────────────────────────────
# Installation PostgreSQL (backend de persistance pour Kong)
# Utilise le chart bitnami/postgresql avec les values postgres-values.yml
# IMPORTANT : postgresql.enabled=false dans kong-values.yml car on l'installe séparément
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Installation de postgresql:"
DOCKER_CONFIG=$HOME/.docker-helm helm upgrade --install kong-postgresql bitnami/postgresql -n ${KONG_NAMESPACE} -f ${POST_VAL_FILE} --set auth.postgresPassword=${POSTGRES_PASSWORD}
error_CTRL "${?}" "Operation completed"

#─────────────────────────────────────────────────────────────────────────────
# Installation Kong Gateway via Helm
# Déployé dans le namespace kong, configuré pour se connecter au PostgreSQL ci-dessus
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Installation de Kong:"
helm upgrade --install ${KONG_RELEASE} ${KONG_CHART} -n ${KONG_NAMESPACE} -f "${KONG_VAL_FILE}"
error_CTRL "${?}" "Operation completed"

#─────────────────────────────────────────────────────────────────────────────
# Vérification de toutes les ressources créées
#─────────────────────────────────────────────────────────────────────────────
set_message "check" "0" "Vérification et affichage de toutes les ressources dans le namespace ${KONG_NAMESPACE}:"
kubectl get all -n ${KONG_NAMESPACE}
error_CTRL "${?}" "Operation completed"

##
# Commandes utiles post-installation :
#
# Récupérer le mot de passe PostgreSQL (sans TLS) :
#   kubectl get secret kong-ingress-controller-postgresql \
#     -o jsonpath="{.data.postgresql-password}" | base64 -d
#
# Requête SQL directe dans le pod PostgreSQL :
#   kubectl exec -it kong-postgresql-0 -- psql -U kong -d kong -c "SELECT now();"

printf "%b\n"
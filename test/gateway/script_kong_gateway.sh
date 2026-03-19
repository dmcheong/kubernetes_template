#!/usr/bin/env bash
#===============================================================================
# Fichier      : script_kong_gateway.sh
# Description  : Installe Kong Gateway avec PostgreSQL comme backend de données.
#                Kong joue le rôle d'ingress controller et d'API Gateway.
# Prérequis    : helm, kubectl, kubeseal installés — namespace kong absent ou vide
# Note         : ce script n'est pas dans le répertoire install/ par choix
#                pédagogique (séparation installation / test)
#===============================================================================

echo "==> Installation d une gateway avec Kong-Gateway."

#─────────────────────────────────────────────────────────────────────────────
# Fonction utilitaire : ajouter un repo Helm s'il n'existe pas encore
# Usage : add_repo_if_missing <nom> <url>
#─────────────────────────────────────────────────────────────────────────────
echo "==> Vérification du repo helm déjà téléchargée:"
add_repo_if_missing() {
  local name=$1
  local url=$2
  if ! helm repo list | awk '{print $1}' | grep -qx "$name"; then
    echo "Ajout du repo $name"
    helm repo add "$name" "$url"
  else
    echo "Repo $name déjà présent"
  fi
}

# ajout des repos bitnami (PostgreSQL) et kong (Kong Gateway)
add_repo_if_missing bitnami https://charts.bitnami.com/bitnami
add_repo_if_missing kong https://charts.konghq.com
helm repo update >/dev/null 2>&1

#─────────────────────────────────────────────────────────────────────────────
# Namespace kong
#─────────────────────────────────────────────────────────────────────────────
echo "==> Création du namespace kong pour kong gateway:"
kubectl create namespace kong

#─────────────────────────────────────────────────────────────────────────────
# Secret PostgreSQL (en clair — dev uniquement)
# En production : utiliser SealedSecrets (voir ci-dessous)
#─────────────────────────────────────────────────────────────────────────────
echo "==> Création d un secret pour postgresql:"

# calcul du chemin absolu pour être indépendant du répertoire courant
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# application du secret en clair (à NE PAS pousser en production)
kubectl apply -f "$SCRIPT_DIR/kong-gateway-secret.yaml"

#─────────────────────────────────────────────────────────────────────────────
# Chiffrement du secret avec kubeseal
# Le controller SealedSecrets doit être déployé dans kube-system
# La clé publique est récupérée automatiquement depuis le controller
#─────────────────────────────────────────────────────────────────────────────
# chiffrement → génère kong-gateway-sealed-secret.yaml (commitablesûrement)
kubeseal --format yaml < "$SCRIPT_DIR/kong-gateway-secret.yaml" > "$SCRIPT_DIR/kong-gateway-sealed-secret.yaml"

# déploiement du secret chiffré (le controller le déchiffre en Secret standard)
kubectl apply -f "$SCRIPT_DIR/kong-gateway-sealed-secret.yaml"

#─────────────────────────────────────────────────────────────────────────────
# Configuration Docker locale sans modifier l'environnement système
# Nécessaire pour Helm + images privées dans certains environnements
#─────────────────────────────────────────────────────────────────────────────
mkdir -p ~/.docker-helm
printf '{ "auths": {} }\n' > ~/.docker-helm/config.json

#─────────────────────────────────────────────────────────────────────────────
# Installation PostgreSQL (backend de persistance pour Kong)
# Utilise le chart bitnami/postgresql avec les values postgres-values.yml
# IMPORTANT : postgresql.enabled=false dans kong-values.yml car on l'installe séparément
#─────────────────────────────────────────────────────────────────────────────
echo "==> Installation de postgresql:"
DOCKER_CONFIG=$HOME/.docker-helm helm upgrade --install kong-postgresql bitnami/postgresql -f "$SCRIPT_DIR/postgres-values.yml"

#─────────────────────────────────────────────────────────────────────────────
# Installation Kong Gateway via Helm
# Déployé dans le namespace dev, configuré pour se connecter au PostgreSQL ci-dessus
#─────────────────────────────────────────────────────────────────────────────
echo "==> Installation de Kong:"
helm upgrade --install kong kong/ingress -n dev -f "$SCRIPT_DIR/kong-values.yml"

#─────────────────────────────────────────────────────────────────────────────
# Vérification de toutes les ressources créées
#─────────────────────────────────────────────────────────────────────────────
echo "==> Verification et affichage de toutes les ressources:"
kubectl get all -n dev

##
# Commandes utiles post-installation :
#
# Récupérer le mot de passe PostgreSQL (sans TLS) :
#   kubectl get secret kong-ingress-controller-postgresql \
#     -o jsonpath="{.data.postgresql-password}" | base64 -d
#
# Requête SQL directe dans le pod PostgreSQL :
#   kubectl exec -it kong-postgresql-0 -- psql -U kong -d kong -c "SELECT now();"

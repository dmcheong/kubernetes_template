# #!/usr/bin/env bash
# Ce script met en place la partie gateway avec Kong-Gateway. Il est nécessaire d'avoir une persistance avec postgresql.
# Génération d un mot de passe pour un environnent de test en l absence de la mise en place des certificats TLS
# avec une commande kubectl. 

# Check if helm repo already set
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

# Update helm repo for bitnami/postgres and kong
add_repo_if_missing bitnami https://charts.bitnami.com/bitnami
add_repo_if_missing kong https://charts.konghq.com
helm repo update >/dev/null 2>&1

# no certificat TLS up ==> Create secret for postgresql kong
echo "==> Création d un secret pour postgresql:"
if ! kubectl get secret kong-ingress-controller-postgresql >/dev/null 2>&1; then
  kubectl create secret generic kong-ingress-controller-postgresql \
    --from-literal=postgresql-password=motdepassefort
else
  echo "Secret déjà existant"
fi

# create repository for helm and docker without update linux environnement docker already set
mkdir -p ~/.docker-helm
printf '{ "auths": {} }\n' > ~/.docker-helm/config.json


# get abolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create postgresq for kong
echo "==> Installation de postgresql:"
DOCKER_CONFIG=$HOME/.docker-helm helm upgrade --install kong-postgresql bitnami/postgresql -f "$SCRIPT_DIR/postgres-values.yml"

# get abolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create kong ingres
echo "==> Installation de Kong:"
helm upgrade --install kong kong/ingress -n dev -f "$SCRIPT_DIR/kong-values.yml"

# check all ressource about kong
echo "==> Verification et affichage de toutes les ressources:"
kubectl get all -n dev

##
# without certificat TLS, you can get secret password with cmd
# kubectl get secret kong-ingress-controller-postgresql -o jsonpath="{.data.postgresql-password}" | base64 -d
 
# request in kong-postgres sql pod
# kubectl exec -it kong-postgresql-0 -- psql -U kong -d kong -c "SELECT now();"
# password 


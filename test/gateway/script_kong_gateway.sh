# #!/usr/bin/env bash
# This script set a gateway with Kong-Gateway. It s necessary to have a persistance with postgresql.
# In test environnement, generate a password without setting a TLS certificates with command kubectl.
# This script is not with install repertory for understanding 

echo "==> Installation d une gateway avec Kong-Gateway."

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

# create namespace for kong gateway
echo "==> Création du namespace kong pour kong gateway:"
kubectl create namespace kong

# no certificat TLS up ==> Create secret for postgresql kong
echo "==> Création d un secret pour postgresql:"

# get abolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# set secret for postgresql
kubectl apply -f "$SCRIPT_DIR/kong-gateway-secret.yaml"

# get abolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# crypt secret with kubeseal
# public key in controller kube-system alreadu set, juste use it
kubeseal --format yaml < "$SCRIPT_DIR/kong-gateway-secret.yaml" > "$SCRIPT_DIR/kong-gateway-sealed-secret.yaml"

# get abolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# use and deploy kong gatexay sealed secret
kubectl apply -f "$SCRIPT_DIR/kong-gateway-sealed-secret.yaml"

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


#!/usr/bin/env bash

# This script check or update last version (set in the script) of Sealed-Secret
# Install with bitnami/github

# official Sealed Secrets repository
REPO="bitnami-labs/sealed-secrets"

# Function : get last tag GitHub
get_latest_github_tag() {
  local repo="$1"
  curl -fsSI "https://github.com/${repo}/releases/latest" \
    | tr -d '\r' \
    | awk -F': ' 'tolower($1)=="location"{print $2}' \
    | awk -F/ '{print $NF}' \
    | tail -n1
}

# get last github repository with last tag
echo "==> Détection de la dernière release de Sealed-Secrets ..."
LATEST_TAG="$(get_latest_github_tag "$REPO")"

if [[ -z "${LATEST_TAG:-}" ]]; then
  echo "==> ERREUR: impossible de récupérer la dernière release GitHub."
fi

echo "==> Dernière release détectée : $LATEST_TAG"
echo
echo "==> Vérification du controller sealed-secrets dans le namespace kube-system ..."

# check if controller deployment already set
if kubectl -n kube-system get deploy sealed-secrets-controller >/dev/null 2>&1; then
  echo "==> Controller déjà installé/déployé dans le namespace kube-system."
else
  echo "==> Controller absent dans le namespace kube-system -> installation depuis $LATEST_TAG"
  kubectl apply -f "https://github.com/${REPO}/releases/download/${LATEST_TAG}/controller.yaml"
fi

echo
echo "==> Vérification finale:"
kubectl -n kube-system get deploy sealed-secrets-controller
echo
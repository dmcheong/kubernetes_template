#!/usr/bin/env bash
# script testing deployment in local

# get abolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# create deployment
echo "==> Création d un déploiement:"
kubectl apply -f "$SCRIPT_DIR/../template/deployment/nginx-deployment.yml"

# get replica from deployment
kubectl get rs

# check pods in dev namespace
echo "==> Liste des pods dans l environnement namespaces -> dev:"
kubectl get pods -n dev
echo "==> Liste des pods avec pour nom de app -> nginx:"
kubectl get pods -l app=nginx

# get abolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# check with kube-score
echo "==> Analyse du déploiement:"
kube-score score "$SCRIPT_DIR/../template/deployment/nginx-deployment.yml"

#!/usr/bin/env bash
# script testing namespaces in local
# specifique for namespace traefik

# get namespaces list
echo "==> Liste de tous les environnement namespaces:"
kubectl get namespaces

##
# create namespace -> traefik for test
echo "==> Création d un environnement namespace -> traefik:"
if kubectl get namespace traefik >/dev/null 2>&1; then
  echo "==> Namespace -> traefik existe déjà, on continue."
else
  kubectl create namespace traefik
fi
echo "==> Vérification de la liste des namespaces pour -> traefik:"
kubectl get namespaces traefik

# describe namespaces -> traefik
echo "==> Description du namespace -> traefik:"
kubectl describe namespace traefik

# check default namespace
echo "==> Vérification de l environnement namespace par défaut -> dev:"
kubectl config view --minify | grep namespace

# get events from namespace -> traefik
echo "==> Liste de tous les évènements de l environnement namespace -> traefik"
kubectl get events -n traefik

# delete namespace
# kubectl delete namespace traefik
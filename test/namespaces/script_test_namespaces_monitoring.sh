#!/usr/bin/env bash
# script testing namespaces in local
# specifique for namespace monitoring

# get namespaces list
echo "==> Liste de tous les environnement namespaces:"
kubectl get namespaces

##
# create namespace -> monitoring for test
echo "==> Création d un environnement namespace -> monitoring:"
if kubectl get namespace monitoring >/dev/null 2>&1; then
  echo "==> Namespace -> monitoring existe déjà, on continue."
else
  kubectl create namespace monitoring
fi
echo "==> Vérification de la liste des namespaces pour -> monitoring:"
kubectl get namespaces monitoring

# describe namespaces -> monitoring
echo "==> Description du namespace -> monitoring:"
kubectl describe namespace monitoring

# check default namespace
echo "==> Vérification de l environnement namespace par défaut -> dev:"
kubectl config view --minify | grep namespace

# get events from namespace -> monitoring
echo "==> Liste de tous les évènements de l environnement namespace -> monitoring"
kubectl get events -n monitoring

# delete namespace
# kubectl delete namespace monitoring
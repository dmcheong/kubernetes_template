#!/usr/bin/env bash
# script testing namespaces in local

# get namespaces list
echo "==> Liste de tous les environnement namespaces:"
kubectl get namespaces

# get specifique namespace
echo "==> Contenu du pod de base kube-system:"
kubectl get pod -n kube-system

##
# create namespace -> dev for test
echo "==> Création d un environnement namespace -> dev:"
if kubectl get namespace dev >/dev/null 2>&1; then
  echo "==> Namespace -> dev existe déjà, on continue."
else
  kubectl create namespace dev
fi
echo "==> Vérification de la liste des namespaces pour -> dev:"
kubectl get namespaces

# describe namespaces -> dev
echo "==> Description du namespace -> dev:"
kubectl describe namespace dev

# set default namespace for inline cmd
echo "==> Configurer par défaut l environnement namespace -> dev:"
kubectl config set-context --current --namespace=dev

# check default namespace
echo "==> Vérification de l environnement namespace par défaut -> dev:"
kubectl config view --minify | grep namespace

# get events from namespace -> dev
echo "==> Liste de tous les évènements de l environnement namespace -> dev"
kubectl get events -n dev

# delete namespace
# kubectl delete namespace dev
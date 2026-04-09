#!/usr/bin/env bash
# script testing namespaces in local
# specifique for namespace traefik

# get namespaces list
set_message "info" "0" "Liste de tous les namespaces:"
kubectl get namespaces

##
# create namespace -> traefik for test
set_message "info" "0" "Création d un environnement namespace -> traefik:"
if kubectl get namespace traefik >/dev/null 2>&1; then
  set_message "EdWMessage" "0" "Namespace -> traefik existe déjà, on continue."
else
  kubectl create namespace traefik
fi
set_message "check" "0" "Vérification de la liste des namespaces pour -> traefik:"
kubectl get namespaces traefik

# describe namespaces -> traefik
set_message "info" "0" "Description du namespace -> traefik:"
kubectl describe namespace traefik

# check default namespace
set_message "check" "0" "Vérification de l environnement namespace par défaut -> dev:"
kubectl config view --minify | grep namespace

# get events from namespace -> traefik
set_message "debug" "0" "Liste de tous les évènements de l environnement namespace -> traefik"
kubectl get events -n traefik

# delete namespace
# kubectl delete namespace traefik
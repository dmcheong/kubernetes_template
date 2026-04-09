#!/usr/bin/env bash
# script testing namespaces in local
# specifique for namespace monitoring

# get namespaces list
set_message "info" "0" "Liste de tous les environnement namespaces:"
kubectl get namespaces

##
# create namespace -> monitoring for test
set_message "info" "0" "Création d un environnement namespace -> monitoring:"
if kubectl get namespace monitoring >/dev/null 2>&1; then
  set_message "EdWMessage" "0" "Namespace -> monitoring existe déjà, on continue."
else
  kubectl create namespace monitoring
fi
set_message "check" "0" "Vérification de la liste des namespaces pour -> monitoring:"
kubectl get namespaces monitoring

# describe namespaces -> monitoring
set_message "info" "0" "Description du namespace -> monitoring:"
kubectl describe namespace monitoring

# check default namespace
set_message "check" "0" "Vérification de l environnement namespace par défaut -> dev:"
kubectl config view --minify | grep namespace

# get events from namespace -> monitoring
set_message "info" "0" "Liste de tous les évènements de l environnement namespace -> monitoring"
kubectl get events -n monitoring

# delete namespace
# kubectl delete namespace monitoring
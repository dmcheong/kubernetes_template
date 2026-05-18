#!/usr/bin/env bash
#===============================================================================
# Fichier      : script_test_namespaces_developpement.sh
# Description  : Crée le namespace developpement servant d'exemple pour le Pod Security Admission (ici restricted).
# Prérequis    : kubectl disponible, cluster Minikube démarré
#===============================================================================
set_message "info" "0" "Gestion des namespaces."
printf "%b\n"

# Utilisation du paramètre set_message "debug" "0" ""
DEBUG_MODE="1"

#─────────────────────────────────────────────────────────────────────────────
# Vue d'ensemble des namespaces existants
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Liste de tous les environnements namespaces:"
kubectl get namespaces
error_CTRL "${?}" "Operation completed"

# observer les pods du namespace système (kube-dns, kube-proxy, metrics-server…)
set_message "info" "0" "Contenu du pod de base kube-system:"
kubectl get pod -n kube-system
error_CTRL "${?}" "Operation completed"

##
#─────────────────────────────────────────────────────────────────────────────
# Création du namespace developpement (idempotent)
# Le namespace developpement isole toutes les ressources de test du reste du cluster
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Création d un environnement namespace -> developpement:"
if kubectl get namespace developpement >/dev/null 2>&1; then
  set_message "EdWMessage" "1" "Namespace -> developpement existe déjà, on continue."
else
  kubectl create namespace developpement
  error_CTRL "${?}" "Operation completed"
fi

#─────────────────────────────────────────────────────────────────────────────
# ATTENTION: La commande qui suit va restreindre tous les pods mal configuré dans le namespace developpement
#   pour renforcer la sécurité et respecter les bonnes pratiques du PSA
#─────────────────────────────────────────────────────────────────────────────
kubectl label ns developpement \
  pod-security.kubernetes.io/enforce=baseline \
  pod-security.kubernetes.io/warn=restricted \
  pod-security.kubernetes.io/audit=restricted \
  --overwrite
error_CTRL "${?}" "Operation completed"

set_message "check" "0" "Vérification de la liste des namespaces pour -> developpement:"
kubectl get namespaces developpement
error_CTRL "${?}" "Operation completed"

# détail du namespace : labels, annotations, état, quotas
set_message "info" "0" "Description du namespace -> developpement:"
kubectl describe namespace developpement
error_CTRL "${?}" "Operation completed"

#─────────────────────────────────────────────────────────────────────────────
# Configuration du contexte kubectl
# Définit dev comme namespace par défaut pour éviter -n dev sur chaque commande
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Configurer par défaut l environnement namespace -> dev:"
kubectl config set-context --current --namespace=dev
error_CTRL "${?}" "Operation completed"

set_message "check" "0" "Vérification de l environnement namespace par défaut -> dev:"
kubectl config view --minify | grep dev
error_CTRL "${?}" "Operation completed"

#─────────────────────────────────────────────────────────────────────────────
# Suivi des événements du namespace (utile pour le debug)
#─────────────────────────────────────────────────────────────────────────────
set_message "debug" "0" "Liste de tous les évènements de l environnement namespace -> developpement"
kubectl get events -n developpement
error_CTRL "${?}" "Operation completed"

# suppression du namespace (décommenter si nécessaire) :
# set_message "info" "0" "Suppression de l environnement namespace -> developpement"
# kubectl delete namespace developpement
# error_CTRL "${?}" "Operation completed"

printf "%b\n"
#!/usr/bin/env bash
#===============================================================================
# Fichier      : script_test_namespaces.sh
# Description  : Crée le namespace dev et le configure comme namespace par défaut.
# Prérequis    : kubectl disponible, cluster Minikube démarré
#===============================================================================

#─────────────────────────────────────────────────────────────────────────────
# Vue d'ensemble des namespaces existants
#─────────────────────────────────────────────────────────────────────────────
echo "==> Liste de tous les environnement namespaces:"
kubectl get namespaces

# observer les pods du namespace système (kube-dns, kube-proxy, metrics-server…)
echo "==> Contenu du pod de base kube-system:"
kubectl get pod -n kube-system

##
#─────────────────────────────────────────────────────────────────────────────
# Création du namespace dev (idempotent)
# Le namespace dev isole toutes les ressources de test du reste du cluster
#─────────────────────────────────────────────────────────────────────────────
echo "==> Création d un environnement namespace -> dev:"
if kubectl get namespace dev >/dev/null 2>&1; then
  echo "==> Namespace -> dev existe déjà, on continue."
else
  kubectl create namespace dev
fi

echo "==> Vérification de la liste des namespaces pour -> dev:"
kubectl get namespaces

# détail du namespace : labels, annotations, état, quotas
echo "==> Description du namespace -> dev:"
kubectl describe namespace dev

#─────────────────────────────────────────────────────────────────────────────
# Configuration du contexte kubectl
# Définit dev comme namespace par défaut pour éviter -n dev sur chaque commande
#─────────────────────────────────────────────────────────────────────────────
echo "==> Configurer par défaut l environnement namespace -> dev:"
kubectl config set-context --current --namespace=dev

echo "==> Vérification de l environnement namespace par défaut -> dev:"
kubectl config view --minify | grep namespace

#─────────────────────────────────────────────────────────────────────────────
# Suivi des événements du namespace (utile pour le debug)
#─────────────────────────────────────────────────────────────────────────────
echo "==> Liste de tous les évènements de l environnement namespace -> dev"
kubectl get events -n dev

# suppression du namespace (décommenter si nécessaire) :
# kubectl delete namespace dev

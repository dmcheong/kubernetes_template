#!/usr/bin/env bash
#===============================================================================
# Fichier      : script_test_deployment.sh
# Description  : Déploie nginx dans le namespace dev et analyse le manifeste
#                avec kube-score pour vérifier les bonnes pratiques.
# Prérequis    : namespace dev créé, kubectl disponible, kube-score installé
#===============================================================================
set_message "info" "0" "Gestion des déploiements"
printf "%b\n"

# chemin absolu pour référencer les templates indépendamment du répertoire courant
DEPL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#─────────────────────────────────────────────────────────────────────────────
# Création du Deployment nginx (3 réplicas, namespace dev)
# Le manifeste nginx-deployment.yml inclut les annotations Prometheus pour
# le scraping automatique des métriques
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Création d un déploiement:"
kubectl apply -f "$DEPL_DIR/../template/deployment/nginx-deployment.yml"

# vérification des ReplicaSets créés par le Deployment
set_message "info" "0" "Liste des replicasets"
kubectl get rs

#─────────────────────────────────────────────────────────────────────────────
# Vérification des pods déployés
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Liste des pods dans l environnement namespaces -> dev:"
kubectl get pods -n dev

# filtrage par label app=nginx (selector du Deployment)
set_message "info" "0" "Liste des pods avec pour nom de app -> nginx:"
kubectl get pods -l app=nginx

#─────────────────────────────────────────────────────────────────────────────
# Analyse du manifeste avec kube-score
# kube-score détecte les problèmes de sécurité et de configuration Kubernetes
# Ne pas mettre le kube score en production à cause du path en clair
# (absence de resource limits, liveness probe manquante, etc.)
#─────────────────────────────────────────────────────────────────────────────
set_message "debug" "0" "Analyse du déploiement:"
kube-score score "$DEPL_DIR/../template/deployment/nginx-deployment.yml"

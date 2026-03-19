#!/usr/bin/env bash
#===============================================================================
# Fichier      : script_test_deployment.sh
# Description  : Déploie nginx dans le namespace dev et analyse le manifeste
#                avec kube-score pour vérifier les bonnes pratiques.
# Prérequis    : namespace dev créé, kubectl disponible, kube-score installé
#===============================================================================

# chemin absolu pour référencer les templates indépendamment du répertoire courant
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#─────────────────────────────────────────────────────────────────────────────
# Création du Deployment nginx (3 réplicas, namespace dev)
# Le manifeste nginx-deployment.yml inclut les annotations Prometheus pour
# le scraping automatique des métriques
#─────────────────────────────────────────────────────────────────────────────
echo "==> Création d un déploiement:"
kubectl apply -f "$SCRIPT_DIR/../template/deployment/nginx-deployment.yml"

# vérification des ReplicaSets créés par le Deployment
kubectl get rs

#─────────────────────────────────────────────────────────────────────────────
# Vérification des pods déployés
#─────────────────────────────────────────────────────────────────────────────
echo "==> Liste des pods dans l environnement namespaces -> dev:"
kubectl get pods -n dev

# filtrage par label app=nginx (selector du Deployment)
echo "==> Liste des pods avec pour nom de app -> nginx:"
kubectl get pods -l app=nginx

#─────────────────────────────────────────────────────────────────────────────
# Analyse du manifeste avec kube-score
# kube-score détecte les problèmes de sécurité et de configuration Kubernetes
# (absence de resource limits, liveness probe manquante, etc.)
#─────────────────────────────────────────────────────────────────────────────
echo "==> Analyse du déploiement:"
kube-score score "$SCRIPT_DIR/../template/deployment/nginx-deployment.yml"

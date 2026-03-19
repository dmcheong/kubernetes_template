#!/usr/bin/env bash
#===============================================================================
# Fichier      : test_replicatsets.sh
# Description  : Test et formation sur les ReplicaSets Kubernetes.
#                Un ReplicaSet garantit qu'un nombre précis de Pods identiques
#                sont toujours en cours d'exécution.
# Note         : En pratique, on ne crée pas de ReplicaSet directement —
#                on crée un Deployment qui gère le ReplicaSet pour permettre
#                les rolling updates et les rollbacks.
#===============================================================================

#─────────────────────────────────────────────────────────────────────────────
# Vérification de l'environnement
#─────────────────────────────────────────────────────────────────────────────
echo "==> Liste de tous les environnement namespaces:"
kubectl get namespaces

# configurer dev comme espace de noms par défaut
echo "==> Configurer par défaut l environnement namespace -> dev"
kubectl config set-context --current --namespace=dev

#─────────────────────────────────────────────────────────────────────────────
# Déploiement du ReplicaSet nginx (3 réplicas)
# nginx-replicaset.yml crée 3 pods nginx dans dev et maintient ce nombre
# même si un pod est supprimé manuellement
#─────────────────────────────────────────────────────────────────────────────
echo "==> Application d'un replicaset depuis un fichier.yml"
kubectl apply -f ./../template/nginx-replicaset.yml

# vérifier que les 3 pods sont bien créés
echo "==> Liste des pods dans le namespace -> dev pour obrserver l application du replicaset:"
kubectl get pods -n dev

##
#─────────────────────────────────────────────────────────────────────────────
# Test de résilience
# Supprimer manuellement un pod → le ReplicaSet en recréera un automatiquement
#─────────────────────────────────────────────────────────────────────────────
# kubectl delete pod <name_pod>
# kubectl get pods -n dev
# → toujours 3 pods (le ReplicaSet a recréé le pod manquant)

##
#─────────────────────────────────────────────────────────────────────────────
# Mise à l'échelle en ligne de commande
#─────────────────────────────────────────────────────────────────────────────
# kubectl scale rs nginx-replicaset --replicas=5
# kubectl get pods -n dev
# note : si les pods sont déjà actifs il n'y a pas de mise à jour directe

#─────────────────────────────────────────────────────────────────────────────
# Analyse du manifeste avec kube-score
#─────────────────────────────────────────────────────────────────────────────
# kube-score score ./../template/nginx-replicaset.yml

#!/usr/bin/env bash
#===============================================================================
# Fichier      : manual_test_deployment.sh
# Description  : Guide de formation sur les Deployments Kubernetes.
#                Fichier non utilisé pour l'automatisation — entraînement manuel.
# Usage        : script à exécuter ligne par ligne pour l'apprentissage
#===============================================================================

#─────────────────────────────────────────────────────────────────────────────
# Vérification de l'environnement
#─────────────────────────────────────────────────────────────────────────────
# lister tous les namespaces disponibles
echo "==> Liste de tous les environnements namespaces:"
kubectl get namespaces

# configurer dev comme namespace par défaut pour les commandes inline
echo "==> Configurer par défaut l environnement namespace -> dev:"
kubectl config set-context --current --namespace=dev

#─────────────────────────────────────────────────────────────────────────────
# Préparation : créer les pods de test (dépendance du script de pods)
#─────────────────────────────────────────────────────────────────────────────
echo "==> Exécution du script de création des pods:"
source ./../pods/script_test_pods.sh

# lister toutes les ressources après création des pods
echo "==> Liste de toutes les ressources créées:"
kubectl get all
# pour supprimer une ressource spécifique :
# kubectl delete <ressource> <name>

#─────────────────────────────────────────────────────────────────────────────
# Création d'un Deployment
# Un Deployment gère le cycle de vie des Pods (création, mise à jour, rollback)
# et garantit que le nombre de réplicas voulu est toujours actif.
#─────────────────────────────────────────────────────────────────────────────
echo "==> Création d un déploiement:"
kubectl apply -f ./../template/deployment/nginx-deployment.yml

# vérification des pods dans dev
echo "==> Liste des pods dans l environnement namespaces -> dev:"
kubectl get pods -n dev

#─────────────────────────────────────────────────────────────────────────────
# Test de résilience : le Deployment recrée automatiquement les pods supprimés
# kubectl delete pod <pod_name>
# puis kubectl get pods -n dev → un nouveau pod est recréé
#─────────────────────────────────────────────────────────────────────────────

#─────────────────────────────────────────────────────────────────────────────
# Mise à l'échelle en ligne de commande (sans modifier le YAML)
#─────────────────────────────────────────────────────────────────────────────
echo "==> Application en ligne de commande d une mise à jour du nbrs de réplicas du déploiement:"
kubectl scale deployment nginx-deployment --replicas=5
# note : si nginx-deployment.yml est mis à jour et appliqué de nouveau,
# le nombre de pods revient à la valeur définie dans le fichier YAML.

#─────────────────────────────────────────────────────────────────────────────
# Mise à jour de l'image (rolling update)
# Kubernetes crée d'abord les nouveaux pods avant de supprimer les anciens
# pour garantir la disponibilité (zero-downtime update)
#─────────────────────────────────────────────────────────────────────────────
echo "==> Modification en ligne de commande de la version l image deployé:"
kubectl set image deployment/nginx-deployment nginx=nginx:1.23

# attendre la fin du rolling update
echo "==> Mise à jour des pods avec la nouvelle image:"
kubectl rollout status deployment nginx-deployment

# vérifier que tous les pods utilisent la nouvelle image
echo "==> Liste des pods dans l environnement namespaces -> dev pour observer la nouvelle image:"
kubectl get pods -n dev

echo "==> Description de l image deployé:"
kubectl describe deployment nginx-deployment | grep Image

#─────────────────────────────────────────────────────────────────────────────
# Rollback : annuler la dernière mise à jour
#─────────────────────────────────────────────────────────────────────────────
echo "==> Rétroaction de la mise à jour du déploiement, ici de l image:"
kubectl rollout undo deployment nginx-deployment

#─────────────────────────────────────────────────────────────────────────────
# Analyse du manifeste avec kube-score
#─────────────────────────────────────────────────────────────────────────────
echo "==> Analyse du déploiement:"
kube-score score ./../template/deployment/nginx-deployment.yml

#!/usr/bin/env bash
#===============================================================================
# Fichier      : script_test_services.sh
# Description  : Déploie et teste les services ClusterIP et NodePort pour nginx.
# Prérequis    : namespace dev créé, Deployment nginx déployé
#===============================================================================

#─────────────────────────────────────────────────────────────────────────────
# Vérification des prérequis : le Deployment nginx doit être actif
#─────────────────────────────────────────────────────────────────────────────
echo "==> Vérification du déploiement avant la mise en place des services:"
kubectl get deployment.app

# listage des pods avec leur IP pour comprendre la sélection par labels
echo "==> Liste des pods dans le déploiement spécifique:"
kubectl get pods -o wide

##
#─────────────────────────────────────────────────────────────────────────────
# Service ClusterIP
# Expose nginx sur une IP fixe interne au cluster (inaccessible depuis l'extérieur)
# Sélectionne les pods via le label app=nginx
#─────────────────────────────────────────────────────────────────────────────
# chemin absolu pour les templates
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Création du service clusterip:"
kubectl apply -f "$SCRIPT_DIR/../template/service/nginx-clusterip-service.yml"

echo "==> Vérification de la liste des services:"
kubectl get services

#─────────────────────────────────────────────────────────────────────────────
# Test de connectivité interne au cluster
# Un pod temporaire busybox est créé pour simuler une communication inter-services
# (équivalent à ce que ferait un microservice interne)
#─────────────────────────────────────────────────────────────────────────────
echo "==> Cette section est un test de connexion sur un pod temporaire:"

echo "==> Création d un pod temporaire:"
kubectl run test-pod --image=busybox --restart=Never -- sleep 3600

# attendre que le pod soit prêt avant de l'utiliser
echo "==> Temps d attente avec latence volontaire pour le pod temporaire pour éviter des erreurs."
kubectl wait --for=condition=Ready pod/test-pod --timeout=30s

# requête HTTP vers le service ClusterIP depuis l'intérieur du cluster
echo "==> Ouverture du terminal du pod pour exécuté un test de connexion au cluster via le pod:"
kubectl exec -it test-pod -- sh -c "wget -qO- http://nginx-clusterip-service"

# nettoyage du pod temporaire
echo "==> Suppression du pod temporaire:"
kubectl delete pod test-pod

##
#─────────────────────────────────────────────────────────────────────────────
# Service NodePort
# Expose nginx sur le port 30007 de chaque nœud du cluster
# Accessible depuis l'extérieur via <IP_Nœud>:30007
#─────────────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Application du service NodePort:"
kubectl apply -f "$SCRIPT_DIR/../template/service/nginx-nodeport-service.yml"

# obtenir l'IP du nœud Minikube
echo "==> Vérifier l IP du noeud:"
kubectl get nodes -o wide

# avec Minikube, l'IP est accessible via :
# minikube ip
# curl http://$(minikube ip):30007

#!/usr/bin/env bash
#===============================================================================
# Fichier      : script_test_services.sh
# Description  : Déploie et teste les services ClusterIP et NodePort pour nginx.
# Prérequis    : namespace dev créé, Deployment nginx déployé
#===============================================================================
set_message "info" "0" "Gestion des services"
printf "%b\n"

# Utilisation du paramètre set_message "debug" "0" ""
DEBUG_MODE="1"

#─────────────────────────────────────────────────────────────────────────────
# Vérification des prérequis : le Deployment nginx doit être actif
#─────────────────────────────────────────────────────────────────────────────
set_message "check" "0" "Vérification du déploiement avant la mise en place des services:"
kubectl get deployment.app

# listage des pods avec leur IP pour comprendre la sélection par labels
set_message "info" "0" "Liste des pods dans le déploiement spécifique:"
kubectl get pods -o wide

##
#─────────────────────────────────────────────────────────────────────────────
# Service ClusterIP
# Expose nginx sur une IP fixe interne au cluster (inaccessible depuis l'extérieur)
# Sélectionne les pods via le label app=nginx
#─────────────────────────────────────────────────────────────────────────────
# chemin absolu pour les templates
SERV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

set_message "info" "0" "Création du service clusterip:"
kubectl apply -f "$SERV_DIR/../template/service/nginx-clusterip-service.yml"

set_message "check" "0" "Vérification de la liste des services:"
kubectl get services

#─────────────────────────────────────────────────────────────────────────────
# Test de connectivité interne au cluster
# Un pod temporaire busybox est créé pour simuler une communication inter-services
# (équivalent à ce que ferait un microservice interne)
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Cette section est un test de connexion sur un pod temporaire:"

set_message "info" "0" "Création d un pod temporaire:"
kubectl run test-pod --image=busybox --restart=Never -- sleep 3600

# attendre que le pod soit prêt avant de l'utiliser
set_message "debug" "0" "Temps d attente avec latence volontaire pour le pod temporaire pour éviter des erreurs."
kubectl wait --for=condition=Ready pod/test-pod --timeout=30s

# requête HTTP vers le service ClusterIP depuis l'intérieur du cluster
set_message "debug" "0" "Ouverture du terminal du pod pour exécuter un test de connexion au cluster via le pod:"
kubectl exec -it test-pod -- sh -c "wget -qO- http://nginx-clusterip-service"

# nettoyage du pod temporaire
set_message "info" "0" "Suppression du pod temporaire:"
kubectl delete pod test-pod

##
#─────────────────────────────────────────────────────────────────────────────
# Service NodePort
# Expose nginx sur le port 30007 de chaque nœud du cluster
# Accessible depuis l'extérieur via <IP_Nœud>:30007
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Application du service NodePort:"
kubectl apply -f "$SERV_DIR/../template/service/nginx-nodeport-service.yml"

######################### wait
set_message "debug" "0" "Temps d attente avec latence volontaire pour le pod temporaire pour éviter des erreurs; 120s."
# kubectl wait --for=condition=avaible deployment/nginx --timeout=120s
kubectl wait --for=condition=Ready pod -l app=nginx --timeout=120s
#########################

# obtenir l'IP du nœud Minikube
set_message "check" "0" "Vérifier l IP du noeud:"
kubectl get nodes -o wide

# avec Minikube, l'IP est accessible via:
# minikube ip
# curl http://$(minikube ip):30007

########################
# below here to read again

# attendre que le endpoint soit montée sinon erreur de connexion
set_message "check" "0" "Obtention des endpoints du service NodePort:"
until kubectl get endpoints nginx-nodeport-service -n dev \
  -o jsonpath='{.subsets[0].addresses[0].ip}' 2>/dev/null | grep -q .; do
  echo "Waiting for service endpoints..."
  sleep 1
done

# test access app 
set_message "debug" "0" "Test de (from node minikube->localhost):"
minikube ssh -- curl -v http://127.0.0.1:30007

##
# check with kube-score
set_message "debug" "0" "Score du fichier.yml du service NodePort:"
kube-score score "$SERV_DIR/../template/service/nginx-nodeport-service.yml"

printf "%b\n"
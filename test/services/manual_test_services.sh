#!/usr/bin/env bash
#===============================================================================
# Fichier      : manual_test_services.sh
# Description  : Guide de formation sur les Services Kubernetes (ClusterIP, NodePort).
#                Fichier non utilisé pour l'automatisation — entraînement manuel.
#===============================================================================

#─────────────────────────────────────────────────────────────────────────────
# Vérification des prérequis
# Un Service nécessite un Deployment actif pour avoir des Pods à cibler
#─────────────────────────────────────────────────────────────────────────────
kubectl get deployment.app
kubectl get pods -o wide

# si le deployment n'est pas encore créé :
# kubectl apply -f ./../template/deployment/nginx-deployment.yml

##
#─────────────────────────────────────────────────────────────────────────────
# Service ClusterIP
# Par défaut, un Pod a une IP interne éphémère : elle change à chaque redémarrage.
# Le Service ClusterIP attribue une IP stable pour les autres Pods du cluster.
# Route le trafic vers les Pods correspondant au selector (app=nginx)
#─────────────────────────────────────────────────────────────────────────────
kubectl apply -f ./../template/service/nginx-clusterip-service.yml
kubectl get services

##
#─────────────────────────────────────────────────────────────────────────────
# Test de connectivité interne (accès service depuis un autre Pod)
#─────────────────────────────────────────────────────────────────────────────
# créer un pod temporaire pour simuler un client interne
kubectl run test-pod --image=busybox --restart=Never -- sleep 3600

# entrer dans le pod temporaire
kubectl exec -it test-pod -- sh

# depuis le shell du pod :
wget -qO- http://nginx-clusterip-service     # → réponse nginx
# réponse attendue : page HTML nginx (voir template nginx-clusterip-service.yml)

# supprimer les ressources de test
kubectl delete pod test-pod
kubectl delete -f ./../template/service/nginx-clusterip-service.yml

##
#─────────────────────────────────────────────────────────────────────────────
# Service NodePort
# Rend l'application accessible depuis l'extérieur du cluster via
# le port 30007 ouvert sur chaque nœud (plage 30000–32767)
#─────────────────────────────────────────────────────────────────────────────
kubectl apply -f ./../template/service/nginx-nodeport-service.yml
kubectl get nodes -o wide

# tester l'accès externe
curl http://<IP_NODE>:30007

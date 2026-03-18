#!usr/bin/env bash
# services get deployment app in cluster
# set network beetween Pods and expose stable and secure app

# need deployment step
# get deployment list
kubectl get deployment.app

# get pods in relationship
kubectl get pods -o wide

# if deployment not set
# kubectl apply-f ./../template/deployment/nginx-deployment.yml


##
# create cluster service clusterip
# Par défaut, un Pod a une IP interne éphémère, ce qui empêche d’autres Pods d’y accéder de manière stable.
# Un Service de type ClusterIP permet d’attribuer une IP fixe pour rendre l’application accessible aux autres Pods du cluster.

# set service
kubectl apply -f ./../template/service/nginx-clusterip-service.yml

# get services
kubectl get services


## 
# case test services access

# create temporary pods
kubectl run test-pod --image=busybox --restart=Never -- sleep 3600

# open terminal pod
kubectl exec -it test-pod -- sh

# test nginx connexion by service
wget -qO- http://nginx-clusterip-service
# get reponse like ../template/nginx-clusterip-service

# delete temporary/test pod
kubectl delete pod test-pod

# delete clusterip
kubectl delete -f ./../template/service/nginx-clusterip-service.yml


##
# expose outside cluster (NodePort)

# set service
kubectl apply -f ./../template/service/nginx-nodeport-service.yml

# get node ip
kubectl get nodes -o wide

# test access app
curl http://<IP_NODE>:30007


##
# score
kube-score score ./../template/service/nginx-nodeport-service.yml
#!/usr/bin/env bash
# test deployment in kubernetes
# this file.sh is a training for deployment not use for automation

# need to create namespace -> dev

# check namespace env here: 
echo "==> Liste de tous les environnements namespaces:"
kubectl get namespaces

# set default namespace env: dev
echo "==> Configurer par défaut l environnement namespace -> dev:"
kubectl config set-context --current --namespace=dev

# set pods by script
echo "==> Exécution du script de création des pods:"
source ./../pods/script_test_pods.sh

# can delete all others ressources
echo "==> Liste de toutes les ressources créées:"
kubectl get all
#kubectl delete <ressource> <name>

##
# create deployment
echo "==> Création d un déploiement:"
kubectl apply -f ./../template/deployment/nginx-deployment.yml

# check pods in dev namespace
echo "==> Liste des pods dans l environnement namespaces -> dev:"
kubectl get pods -n dev

# test deployment resilient
# kubectl delete pod <pod_name>

# set number of replicas in deployment with cmd 
echo "==> Application en ligne de commande d une mise à jour du nbrs de réplicas du déploiement:"
kubectl scale deployment nginx-deployment --replicas=5

# note: if nginx-deployment.yml is update and cmd set
# => number of pods will be update

## 
# note: with deployment, create new pods before delete when update

# update image for deployment with cmd inline
echo "==> Modification en ligne de commande de la version l image deployé:"
kubectl set image deployment/nginx-deployment nginx=nginx:1.23

# set Pods update
echo "==> Mise à jour des pods avec la nouvelle image:"
kubectl rollout status deployment nginx-deployment

# check every pods use de new image
echo "==> Liste des pods dans l environnement namespaces -> dev pour observer la nouvelle image:"
kubectl get pods -n dev

# check image in use
echo "==> Description de l image deployé:"
kubectl describe deployment nginx-deployment | grep Image

# for undo rollout with cmd inline
echo "==> Rétroaction de la mise à jour du déploiement, ici de l image:"
kubectl rollout undo deployment nginx-deployment

# check with kube-score
echo "==> Analyse du déploiement:"
kube-score score ./../template/deployment/nginx-deployment.yml

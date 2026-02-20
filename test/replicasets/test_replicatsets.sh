#!/usr/bin/env bash
# test replicaset
# replicaset set numbers of pod even in failed case
# this file is for praticing replicaset, file.sh not use

# check namespaces/env
echo "==> Liste de tous les environnement namespaces:"
kubectl get namespaces

# set default namespace for inline cmd
echo "==> Configurer par défaut l environnement namespace -> dev"
kubectl config set-context --current --namespace=dev

# create replicaset
echo "==> Application d'un replicaset depuis un fichier.yml"
kubectl apply -f ./../template/nginx-replicaset.yml

# check pods in dev env
echo "==> Liste des pods dans le namespace -> dev pour obrserver l application du replicaset:"
kubectl get pods -n dev

##
# below here it is about case with a failed pods with replicaset

# case one pod in failed
# kubectl delete pod <name_pod>

# check pods in dev env to find 3 pods even with one manual delete
# kubectl get pods -n dev

##
# inline cmd update replicaset number
# kubectl scale rs nginx-replicaset --replicat=5
# note: can update nginx-replicaset.yml

# check pods in dev env / always check
# kubectl get pods -n dev

# note: if pods are up, there are no direct update

# check replicaset score
# kube-score score ./../template/nginx-replicaset.yml
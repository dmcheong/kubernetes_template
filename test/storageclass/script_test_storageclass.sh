#!usr/bin/env bash
# script testing storageclass in local

## With a real nfs (Network File System) server, set a storageclass but for lab and minimal requirement, not set here

# # get abolute path
# SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# # set storageclass
# echo "==> Création d une StorageClass:"
# kubectl apply -f "$SCRIPT_DIR/../template/storage/storageclass-nfs.yml"

# # check storageclass exist
# echo "==> Liste des StorageClass:"
# kubectl get storageclass

# get abolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# set PersistentVolumeClaim and not a server nfs in dev case
echo "==> Création d une Persistance Volume Claim pour simuler en local un serveur NFS:"
kubectl apply -f "$SCRIPT_DIR/../template/storage/pvc-local.yml"

# check pvc
echo "==> Liste des PersistentVolumeClaim:"
kubectl get pvc

##
# Check data persistence

# get abolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# use pvc in deployment
echo "==> Application du déploiement du PVC via un serveur NFS (NGINX):"
kubectl apply -f "$SCRIPT_DIR/../template/deployment/deployment-nfs.yml"

# pods
echo "==> Listes des pods:"
kubectl get pods

# echo end step storageclass
echo "==> La persistance du volume via un serveur NFS est mis en place."
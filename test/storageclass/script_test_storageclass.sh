#!usr/bin/env bash
# script testing storageclass in local

# get abolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# set service by script
source "$SCRIPT_DIR/../services/script_test_services.sh"

# With a real nfs server, set a storageclaas but for lab and mina=imal requirement, not set here

# # get abolute path
# SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# # set storageclass
# echo "==> Création d une StorageClass:"
# kubectl apply -f "$SCRIPT_DIR/../template/storageclass-nfs.yml"

# check storageclass exist
echo "==> Liste des StorageClass:"
kubectl get storageclass

# get abolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# set PersistentVolumeClaim
echo "==> Création d une  sur un serveur NFS:"
kubectl apply -f "$SCRIPT_DIR/../template/pvc-local.yml"

# check pvc
echo "==> Liste des PersistentVolumeClaim:"
kubectl get pvc

##
# Check data persistence

# get abolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# use pvc in deployment
echo "==> Application du déploiement du PVC dans un serveur NFS:"
kubectl apply -f "$SCRIPT_DIR/../template/deployment-nfs.yml"

# pods
echo "==> Listes des pods:"
kubectl get pods

# echo end step storageclass
echo "==> La persistance du volume via un serveur NFS est mis en place."
#!/usr/bin/env bash
#===============================================================================
# Fichier      : script_test_storageclass.sh
# Description  : Teste la persistance de volumes avec un PVC local (dev)
#                puis déploie une application utilisant ce volume via NFS.
# Prérequis    : namespace dev créé, Minikube démarré
# Note         : la StorageClass NFS réelle est commentée — en environnement
#                de lab, on utilise un PVC local (standard/minikube) à la place
#===============================================================================
set_message "info" "0" "Gestion des Persistent Volume Claim ou storageclass."
printf "%b\n"

#─────────────────────────────────────────────────────────────────────────────
# StorageClass NFS (désactivée pour le lab)
# En production avec un vrai serveur NFS (192.168.49.2 par exemple) :
#   kubectl apply -f "$STOR_DIR/../template/storage/storageclass-nfs.yml"
# Provisioner utilisé : nfs.csi.k8s.io (CSI NFS driver)
#─────────────────────────────────────────────────────────────────────────────
# STOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# set_message "info" "0" "Création d une StorageClass:"
# kubectl apply -f "$STOR_DIR/../template/storage/storageclass-nfs.yml"
# set_message "info" "0" "Liste des StorageClass:"
# kubectl get storageclass

# chemin absolu pour les templates
STOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#─────────────────────────────────────────────────────────────────────────────
# PersistentVolumeClaim local (pvc-local)
# En dev : utilise la StorageClass "standard" de Minikube (provisionnement local)
# Remplace le PVC NFS pour un lab sans serveur NFS
# Taille : 1Gi, accès : ReadWriteOnce (un seul nœud en lecture-écriture)
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Création d une Persistance Volume Claim pour simuler en local un serveur NFS:"
kubectl apply -f "$STOR_DIR/../template/storage/pvc-local.yml"

set_message "check" "0" "Liste des PersistantVolumeClaim:"
kubectl get pvc

##
#─────────────────────────────────────────────────────────────────────────────
# Déploiement utilisant le PVC
# deployment-nfs.yml monte le volume pvc-local dans /usr/share/nginx/html
# Ainsi, les fichiers servis par nginx sont persistés dans le volume
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Application du déploiement du PVC via un serveur NFS (NGINX):"
kubectl apply -f "$STOR_DIR/../template/deployment/deployment-nfs.yml"

set_message "check" "0" "Listes des pods:"
kubectl get pods

set_message "info" "0" "La persistance du volume via un serveur NFS est mis en place."

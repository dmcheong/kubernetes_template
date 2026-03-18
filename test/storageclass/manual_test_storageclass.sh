#!usr/bin/env bash

# Dans Kubernetes, une StorageClass permet d automatiser la création et la gestion des volumes persistants.
# Cela simplifie le stockage pour les applications, offrant flexibilité et scalabilité. Dans ce TP, 
# nous allons utiliser un serveur NFS (Network File System) comme backend de stockage et configurer une StorageClass pour provisionner dynamiquement des volumes.

# make sur miniube for test is launched
minikube start

# check cluster infos
kubectl cluster-info

##
# check if nfs serveur is installled or install

# install nfs server in case
sudo apt update
sudo apt install nfs-server -y

# create sharing folder
sudo mkdir -p /data

# add in sharing file
echo "/data *(rw,sync,no_subtree_check)" | sudo tee -a /etc/exports

# reload nfs service
sudo systemctl restart nfs-kernel-server

# set storageclass
kubectl apply -f ./../template/storage/storageclass-nfs.yml

# check storageclass
kubectl get storageclass


##
# create persistentvolumeclaim

# set pvc
kubectl apply -f ./../template/storage/pvc-nfs.yml

# check pvc
kubectl get pvc

##
# use pvc in deployment
kubectl apply -f ./../template/deployment/deployment-nfs.yml

# pods
kubctl get pods


##
# check data persistence

# check file in pod
kubectl exec -it <pod-name> -- /bin/sh

# add file in volume
echo "Hello Kubernetes Storage" > /usr/share/nginx/html/index.html

# exit pod and delete it
kubectl delete pod <pod-name>

# create pod and check if file still here
kubectl exec -it <new-pod-name> -- cat /usr/share/nginx/html/index.


##
# debug and troubleshooting

# check pvc event
kubectl describe pvc pvc-nfs

# check driver csi logs
kubectl logs -n kube-system -l app=csi-nfs-controller

# check if volume set in pod
kubectl exec -it <pod-name> -- df -h

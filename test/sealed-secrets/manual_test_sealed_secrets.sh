#!usr/bin/env bash
# script testing sealedsecret in local

##
# without kubseal or sealedsecret

# get abolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# get active cluster
kubectl config get-contexts

# set default dev env
kubctl config set-context --current --namespace=dev

# from a file example
echo "mon-mot-de-passe" > db-password.txt
kubectl create secret generic db-secret --from-file=password=db-password.txt

# to get it
kubectl get secret db-secret -o yaml

# check kubeseal version
kubeseal --version

# actual kubeseal version 0.28.0
kubeseal version: 0.28.0


## 
# Le SealedSecrets Controller est un composant qui permet de déchiffrer automatiquement les SealedSecrets en Secrets Kubernetes classiques.

# install sealed-secrets by helm
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install sealed-secrets bitnami/sealed-secrets --namespace kube-

# check if controller is up
kubectl get pods -n kube-system | grep sealed-secrets

# set sealed-secret
kubectl apply -f ../secret/my-secrets.yml

# check content
kubectl get secret mon-secret -o yaml -n dev
# set a .gitignore for secret as usual

# export public key in controller sealedsecrets
kubeseal --fetch-cert --controller-name=sealed-secrets --controller-namespace=kube-system > sealed-secrets.pem

# generate seleadsecret from existing secret
kubeseal --controller-name=sealed-secrets --controller-namespace=kube-system --format=yaml < mon-secret.yaml > monsealedsecret.yaml


##
# use and deployment seleadsecret
kubectl apply -f ../secret/my-secrets.yml

# check sealedsecret
kubectl get sealedsecrets -n dev

# check if keberenets create a standard secret
kubectl get secret monsecret -o jsonpath="{.data.password}" | base64 --decode

## 
# update a sealedsecret
# Un SealedSecret ne peut pas être modifié directement. Il faut générer un nouveau fichier chiffré.

# create a secret updated
kubectl create secret generic monsecret \
  --from-literal=username=admin \
  --from-literal=password=NouveauMotDePasse2024 \
  -o yaml --dry-run=client > mon-secret.yaml

# encrypt new secret
kubeseal --controller-name=sealed-secrets --controller-namespace=kube-system --format=yaml < mon-secret.yaml > monsealedsecret.yaml

# apply new sealedsecret
kubectl apply -f monsealedsecret.yml

# reload pods to set new secret
kubectl delete pod -l app=monapplication
#!usr/bin/env bash
# test deployment in kubernetes
# source: https://gauthier.frama.io/post/vault/

## hashicorp vault

# 
kubectl create ns vault vault-csi

# 
helm repo add hashicorp https://helm.releases.hashicorp.

# 
helm search repo hashicorp/

# 
helm install vault hashicorp/vault \
    --namespace vault \
    -f values.yml \

## secrets-store-csi-driver

# 
helm repo add  secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts

# 
helm install csi-secret-store secrets-store-csi-driver/secrets-store-csi-driver  \
    --namespace vault-csi \
    -f values-secrets-store-csi.yml \

## Initate main node

# 
kubectl exec vault-0 -- vault operator init \
    -key-shares=1 \
    -key-threshold=1 \
    -format=json > cluster-keys.json

# rancher-desktop ? 

## auth kubernetes in vault

# with token root
export VAULT_TOKEN=$(jq -r ".root_token" cluster-keys.json)
export VAULT_ADDR='http://127.0.0.1:8200'

# record of kubernets in vault
source vault_login.sh

# create role and secret
kubectl create ns apps

# bound_service_account_names Nom des services account autorisés
# bound_service_account_namespaces Nom des namespaces autorisés

vault write auth/${clustername}/role/database \
    bound_service_account_names=webapp-sa \
    bound_service_account_namespaces=apps \
    policies=${clustername}-kv-read \
    ttl=20m

# 
# création d'un secrets engine kv
vault secrets enable -path kv kv

# ajout d'une clé pour test
vault kv put kv/apps/webapp-sa/db-pass user=myapp password=supersecret

## Create app
kubectl apply -n apps -f webapp-sa.yml

kubectl apply -n apps -f webapp-sa.yml

kubectl apply -n apps -f deployment.yaml

# check
❯ k exec -it webapp-7dccbc6469-w2689 -- ls -la /mnt/secrets-store/
total 4
drwxrwxrwt    3 root     root           120 Aug 13 06:27 .
drwxr-xr-x    1 root     root          4096 Aug 13 06:27 ..
drwxr-xr-x    2 root     root            80 Aug 13 06:27 ..2022_08_13_06_27_02.1354016230
lrwxrwxrwx    1 root     root            32 Aug 13 06:27 ..data -> ..2022_08_13_06_27_02.1354016230
lrwxrwxrwx    1 root     root            18 Aug 13 06:27 db-password -> ..data/db-password
lrwxrwxrwx    1 root     root            14 Aug 13 06:27 db-user -> ..data/db-user
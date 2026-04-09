#!/bin/bash

clustername="rancher-desktop"
clusterurl="https://kubernetes.default.svc:443"

# Activation de la méthode d'authentification
vault auth enable -path=${clustername} kubernetes

# Je déclare le cluster attaché à kubernetes
vault write auth/${clustername}/config \
    kubernetes_host="${clusterurl}"

ACCESSOR=$(vault auth list -format=json | jq -r ".\"${clustername}/\".accessor")
export ACCESSOR

vault policy write "${clustername}-kv-read" - <<EOF
path "kv/{{identity.entity.aliases.$ACCESSOR.metadata.service_account_namespace}}/{{identity.entity.aliases.$ACCESSOR.metadata.service_account_name}}/*" {
  capabilities = ["read"]
}
EOF

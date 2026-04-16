#!/usr/bin/env bash
#===============================================================================
# Fichier      : script_test_vault_hashicorp.sh
# Description  : Initialise Vault, déverrouille les pods, configure un secret,
#                active l'authentification Kubernetes et déploie une webapp de test.
# Prérequis    : kubectl, jq installés — Vault déployé via Helm dans Kubernetes
# Source       : https://developer.hashicorp.com/vault/tutorials/kubernetes-introduction/kubernetes-minikube-raft#kubernetes-minikube-raft
# Note         : ce script n'est pas dans scripts/bin/ par choix pédagogique
#===============================================================================

VAULT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEBAPP_FILE="${VAULT_DIR}/deployment-01-webapp.yml"
CLUSTER_KEYS_FILE="${VAULT_DIR}/cluster-keys.json"

global_configuration_file="${root_path}/config/global.env"
if [[ -f "${global_configuration_file}" ]]
  then
    . "${global_configuration_file}"
fi

set_message "info" "0" "Exécution du script de configuration de Vault dans le namespace ${HASHICORP_NAMESPACE}."

#─────────────────────────────────────────────────────────────────────────────
# Initialisation de Vault
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Initialisation de Vault sur le pod vault-0."
kubectl exec vault-0 -n ${HASHICORP_NAMESPACE} -- vault operator init -key-shares=1 -key-threshold=1 -format=json > ${CLUSTER_KEYS_FILE}

set_message "check" "0" "Affichage de la clé de déverrouillage Vault"
set_message "EdWMessage" "0" "Ne pas afficher en production"
jq -r '.unseal_keys_b64[]' ${CLUSTER_KEYS_FILE} || true

VAULT_UNSEAL_KEY="$(jq -r '.unseal_keys_b64[]' ${CLUSTER_KEYS_FILE})"
VAULT_ROOT_TOKEN="$(jq -r '.root_token' ${CLUSTER_KEYS_FILE})"

#─────────────────────────────────────────────────────────────────────────────
# Déverrouillage et rattachement des pods au cluster Raft
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Déverrouillage de Vault sur le pod vault-0."
kubectl exec vault-0 -n ${HASHICORP_NAMESPACE} -- vault operator unseal ${VAULT_UNSEAL_KEY}

set_message "info" "0" "Rattachement du pod vault-1 au cluster Raft."
kubectl exec vault-1 -n ${HASHICORP_NAMESPACE} -- vault operator raft join http://vault-0.vault-internal:8200

set_message "info" "0" "Rattachement du pod vault-2 au cluster Raft."
kubectl exec vault-2 -n ${HASHICORP_NAMESPACE} -- vault operator raft join http://vault-0.vault-internal:8200

set_message "info" "0" "Déverrouillage de Vault sur le pod vault-1."
kubectl exec vault-1 -n ${HASHICORP_NAMESPACE} -- vault operator unseal ${VAULT_UNSEAL_KEY}

set_message "info" "0" "Déverrouillage de Vault sur le pod vault-2."
kubectl exec vault-2 -n ${HASHICORP_NAMESPACE} -- vault operator unseal ${VAULT_UNSEAL_KEY}

#─────────────────────────────────────────────────────────────────────────────
# Configuration d'un secret dans Vault
#─────────────────────────────────────────────────────────────────────────────
set_message "check" "0" "Affichage du root token Vault"
set_message "edWMessage" "0" "Ne pas afficher en production"
jq -r '.root_token' ${CLUSTER_KEYS_FILE} || true

set_message "info" "0" "Activation du moteur de secrets kv-v2 sur le chemin secret."
kubectl exec vault-0 -n ${HASHICORP_NAMESPACE} -- /bin/sh -c \
  "VAULT_TOKEN='${VAULT_ROOT_TOKEN}' vault secrets enable -path=secret kv-v2"

set_message "info" "0" "Création du secret secret/webapp/config."
kubectl exec vault-0 -n ${HASHICORP_NAMESPACE} -- /bin/sh -c \
  "VAULT_TOKEN='${VAULT_ROOT_TOKEN}' vault kv put secret/webapp/config username='static-user' password='static-password'"

set_message "check" "0" "Vérification du secret secret/webapp/config."
kubectl exec vault-0 -n ${HASHICORP_NAMESPACE} -- /bin/sh -c \
  "VAULT_TOKEN='${VAULT_ROOT_TOKEN}' vault kv get secret/webapp/config" || true

#─────────────────────────────────────────────────────────────────────────────
# Configuration de l'authentification Kubernetes
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Activation de la méthode d'authentification Kubernetes."
kubectl exec vault-0 -n ${HASHICORP_NAMESPACE} -- /bin/sh -c \
  "VAULT_TOKEN='${VAULT_ROOT_TOKEN}' vault auth enable kubernetes"

set_message "info" "0" "Configuration de la méthode d'authentification Kubernetes."
kubectl exec vault-0 -n ${HASHICORP_NAMESPACE} -- /bin/sh -c \
  "VAULT_TOKEN='${VAULT_ROOT_TOKEN}' vault write auth/kubernetes/config kubernetes_host='https://kubernetes.default.svc:443'"

set_message "info" "0" "Création de la policy Vault webapp."
kubectl exec -i vault-0 -n ${HASHICORP_NAMESPACE} -- /bin/sh -c \
  "VAULT_TOKEN='${VAULT_ROOT_TOKEN}' vault policy write webapp -" <<'EOF'
path "secret/data/webapp/config" {
  capabilities = ["read"]
}
EOF

set_message "info" "0" "Création du rôle Kubernetes webapp."
kubectl exec vault-0 -n ${HASHICORP_NAMESPACE} -- /bin/sh -c \
  "VAULT_TOKEN='${VAULT_ROOT_TOKEN}' vault write auth/kubernetes/role/webapp \
     bound_service_account_names=vault \
     bound_service_account_namespaces=${HASHICORP_NAMESPACE} \
     policies=webapp \
     audience=https://kubernetes.default.svc.cluster.local \
     ttl=24h"

#─────────────────────────────────────────────────────────────────────────────
# Déploiement de la webapp de test
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Déploiement de la webapp de test avec le fichier ${WEBAPP_FILE}."
kubectl apply -n ${HASHICORP_NAMESPACE} --filename ${WEBAPP_FILE} --wait

printf "%b\n"
set_message "check" "0" "Liste des pods dans le namespace ${HASHICORP_NAMESPACE}"
kubectl get pods -n ${HASHICORP_NAMESPACE} || true
printf "%b\n"

#─────────────────────────────────────────────────────────────────────────────
# Accès de test pour les développeurs
#─────────────────────────────────────────────────────────────────────────────
printf "%b\n"
echo "==> Accès utiles:"
echo "Port-forward webapp : kubectl -n ${HASHICORP_NAMESPACE} port-forward $(kubectl -n ${HASHICORP_NAMESPACE} get pod -l app=webapp -o jsonpath="{.items[0].metadata.name}") 8080:8080"
echo "Test HTTP webapp   : curl http://localhost:8080"
printf "%b\n"
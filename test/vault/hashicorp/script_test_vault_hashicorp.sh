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

function Get_Vault_Token_From_File ()
{
  local CLUSTER_KEYS_FILE="${1}"

  VAULT_UNSEAL_KEY="$(jq -r '.unseal_keys_b64[]' "${CLUSTER_KEYS_FILE}")"
  VAULT_ROOT_TOKEN="$(jq -r '.root_token' "${CLUSTER_KEYS_FILE}")"

  Empty_Var_Control "${VAULT_UNSEAL_KEY}" "VAULT_UNSEAL_KEY" "2"
  Empty_Var_Control "${VAULT_ROOT_TOKEN}" "VAULT_ROOT_TOKEN" "2"

  set_message "check" "0" "Affichage de la clé de déverrouillage Vault"
  set_message "warn" "0" "Ne pas afficher en production"
  jq -r '.unseal_keys_b64[]' ${CLUSTER_KEYS_FILE} || true
  error_CTRL "${?}" "Operation completed"
}

function Do_Vault_Init_If_Needed ()
{
  local HASHICORP_NAMESPACE="${1}"
  local CLUSTER_KEYS_FILE="${2}"
  local VAULT_INIT_STATUS=""

  set_message "check" "0" "checking Vault init status on vault-0"

  VAULT_INIT_STATUS="$(kubectl exec vault-0 -n "${HASHICORP_NAMESPACE}" -- vault status -format=json 2>/dev/null | jq -r '.initialized' 2>/dev/null)"

  if [[ "${VAULT_INIT_STATUS}" != "true" ]]
      then
          set_message "info" "0" "Initialisation de Vault sur vault-0."
          kubectl exec vault-0 -n "${HASHICORP_NAMESPACE}" -- vault operator init -key-shares=1 -key-threshold=1 -format=json > "${CLUSTER_KEYS_FILE}"
          error_CTRL "${?}" "Vault init completed"
      else
          set_message "info" "0" "Vault est déjà initialisé."
  fi
}

#─────────────────────────────────────────────────────────────────────────────
# Déverrouillage et rattachement des pods au cluster Raft
#─────────────────────────────────────────────────────────────────────────────

function Do_Vault_Unseal_If_Needed ()
{
  local HASHICORP_NAMESPACE="${1}"
  local VAULT_POD="${2}"
  local VAULT_UNSEAL_KEY="${3}"
  local VAULT_SEAL_STATUS=""

  set_message "check" "0" "checking seal status for ${VAULT_POD}"

  VAULT_SEAL_STATUS="$(kubectl exec "${VAULT_POD}" -n "${HASHICORP_NAMESPACE}" -- vault status -format=json 2>/dev/null | jq -r '.sealed' 2>/dev/null)"

  if [[ "${VAULT_SEAL_STATUS}" = "true" ]]
      then
          set_message "info" "0" "Déverrouillage de Vault sur ${VAULT_POD}."
          kubectl exec "${VAULT_POD}" -n "${HASHICORP_NAMESPACE}" -- vault operator unseal "${VAULT_UNSEAL_KEY}"
          error_CTRL "${?}" "Vault unseal completed on ${VAULT_POD}"
      else
          set_message "info" "0" "${VAULT_POD} est déjà déverrouillé."
  fi
}

function Do_Vault_Raft_Join_If_Needed ()
{
  local HASHICORP_NAMESPACE="${1}"
  local VAULT_ROOT_TOKEN="${2}"
  local VAULT_POD="${3}"
  local VAULT_RAFT_PEERS=""

  set_message "check" "0" "checking raft membership for ${VAULT_POD}"

  VAULT_RAFT_PEERS="$(kubectl exec vault-0 -n "${HASHICORP_NAMESPACE}" -- /bin/sh -c \
    "VAULT_TOKEN='${VAULT_ROOT_TOKEN}' vault operator raft list-peers" 2>/dev/null || true)"

  if echo "${VAULT_RAFT_PEERS}" | grep -q "${VAULT_POD}"
      then
          set_message "info" "0" "${VAULT_POD} est déjà membre du cluster Raft."
      else
          set_message "info" "0" "Rattachement de ${VAULT_POD} au cluster Raft."
          kubectl exec "${VAULT_POD}" -n "${HASHICORP_NAMESPACE}" -- vault operator raft join http://vault-0.vault-internal:8200
          error_CTRL "${?}" "Vault raft join completed on ${VAULT_POD}"
  fi
}

#─────────────────────────────────────────────────────────────────────────────
# Configuration d'un secret dans Vault
#─────────────────────────────────────────────────────────────────────────────

function Do_Vault_Enable_Kv_If_Needed ()
{
  local HASHICORP_NAMESPACE="${1}"
  local VAULT_ROOT_TOKEN="${2}"
  local VAULT_SECRET_ENGINE_STATUS=""

  set_message "check" "0" "checking secret engine secret/"

  VAULT_SECRET_ENGINE_STATUS="$(kubectl exec vault-0 -n "${HASHICORP_NAMESPACE}" -- /bin/sh -c \
    "VAULT_TOKEN='${VAULT_ROOT_TOKEN}' vault secrets list -format=json" 2>/dev/null | jq -r '."secret/".type' 2>/dev/null)"

  if [[ "${VAULT_SECRET_ENGINE_STATUS}" != "kv" ]]
      then
          set_message "info" "0" "Activation du moteur kv-v2 sur secret/."
          kubectl exec vault-0 -n "${HASHICORP_NAMESPACE}" -- /bin/sh -c \
            "VAULT_TOKEN='${VAULT_ROOT_TOKEN}' vault secrets enable -path=secret kv-v2"
          error_CTRL "${?}" "Vault kv-v2 enable completed"
      else
          set_message "info" "0" "Le moteur secret/ existe déjà."
  fi
}

function Do_Vault_Create_Webapp_Secret_If_Needed ()
{
  local HASHICORP_NAMESPACE="${1}"
  local VAULT_ROOT_TOKEN="${2}"

  set_message "check" "0" "checking secret secret/webapp/config"

  kubectl exec vault-0 -n "${HASHICORP_NAMESPACE}" -- /bin/sh -c \
    "VAULT_TOKEN='${VAULT_ROOT_TOKEN}' vault kv get secret/webapp/config" >/dev/null 2>&1

  if [[ "${?}" != "0" ]]
      then
          set_message "info" "0" "Création du secret secret/webapp/config."
          kubectl exec vault-0 -n "${HASHICORP_NAMESPACE}" -- /bin/sh -c \
            "VAULT_TOKEN='${VAULT_ROOT_TOKEN}' vault kv put secret/webapp/config username='static-user' password='static-password'"
          error_CTRL "${?}" "Vault secret creation completed"
      else
          set_message "info" "0" "Le secret secret/webapp/config existe déjà."
  fi
}

#─────────────────────────────────────────────────────────────────────────────
# Configuration de l'authentification Kubernetes
#─────────────────────────────────────────────────────────────────────────────

function Do_Vault_Enable_Kubernetes_Auth_If_Needed ()
{
  local HASHICORP_NAMESPACE="${1}"
  local VAULT_ROOT_TOKEN="${2}"
  local VAULT_AUTH_STATUS=""

  set_message "check" "0" "checking Kubernetes auth method"

  VAULT_AUTH_STATUS="$(kubectl exec vault-0 -n "${HASHICORP_NAMESPACE}" -- /bin/sh -c \
    "VAULT_TOKEN='${VAULT_ROOT_TOKEN}' vault auth list -format=json" 2>/dev/null | jq -r '."kubernetes/".type' 2>/dev/null)"

  if [[ "${VAULT_AUTH_STATUS}" != "kubernetes" ]]
      then
          set_message "info" "0" "Activation de auth/kubernetes."
          kubectl exec vault-0 -n "${HASHICORP_NAMESPACE}" -- /bin/sh -c \
            "VAULT_TOKEN='${VAULT_ROOT_TOKEN}' vault auth enable kubernetes"
          error_CTRL "${?}" "Vault kubernetes auth enable completed"
      else
          set_message "info" "0" "auth/kubernetes est déjà activé."
  fi
}

function Do_Vault_Configure_Kubernetes_Auth ()
{
  local HASHICORP_NAMESPACE="${1}"
  local VAULT_ROOT_TOKEN="${2}"

  set_message "info" "0" "Configuration de auth/kubernetes."

  kubectl exec vault-0 -n "${HASHICORP_NAMESPACE}" -- /bin/sh -c \
    "VAULT_TOKEN='${VAULT_ROOT_TOKEN}' vault write auth/kubernetes/config kubernetes_host='https://kubernetes.default.svc:443'"
  error_CTRL "${?}" "Vault kubernetes auth config completed"
}

function Do_Vault_Write_Webapp_Policy ()
{
  local HASHICORP_NAMESPACE="${1}"
  local VAULT_ROOT_TOKEN="${2}"

  set_message "info" "0" "Création ou mise à jour de la policy webapp."

kubectl exec -i vault-0 -n "${HASHICORP_NAMESPACE}" -- /bin/sh -c \
"VAULT_TOKEN='${VAULT_ROOT_TOKEN}' vault policy write webapp -" <<'EOF'
path "secret/data/webapp/config" {
  capabilities = ["read"]
}
EOF
  error_CTRL "${?}" "Vault policy webapp configured"
}

function Do_Vault_Write_Webapp_Role ()
{
  local HASHICORP_NAMESPACE="${1}"
  local VAULT_ROOT_TOKEN="${2}"

  set_message "info" "0" "Création ou mise à jour du rôle Kubernetes webapp."

  kubectl exec vault-0 -n "${HASHICORP_NAMESPACE}" -- /bin/sh -c \
    "VAULT_TOKEN='${VAULT_ROOT_TOKEN}' vault write auth/kubernetes/role/webapp \
    bound_service_account_names=vault \
    bound_service_account_namespaces=${HASHICORP_NAMESPACE} \
    policies=webapp \
    audience=https://kubernetes.default.svc.cluster.local \
    ttl=24h"
  error_CTRL "${?}" "Vault kubernetes role webapp configured"
}

#─────────────────────────────────────────────────────────────────────────────
# Déploiement de la webapp de test
#─────────────────────────────────────────────────────────────────────────────

function Do_Deploy_Webapp ()
{
  local HASHICORP_NAMESPACE="${1}"
  local WEBAPP_FILE="${2}"

  set_message "info" "0" "Déploiement idempotent de la webapp avec ${WEBAPP_FILE}."

  kubectl apply -n "${HASHICORP_NAMESPACE}" --filename "${WEBAPP_FILE}" --wait
  error_CTRL "${?}" "Webapp deployment completed"
}

#─────────────────────────────────────────────────────────────────────────────
# Exécution de toutes les fonctions du script
#─────────────────────────────────────────────────────────────────────────────

function Do_Vault_Full_Setup ()
{
  ############ STACK_TRACE_BUILDER #####################
  Function_Name="${FUNCNAME[0]}"
  Function_PATH="${Function_PATH}/${Function_Name}"
  ######################################################

  set_message "debug" "0" "current function path : [ ${Function_PATH} ]  | function Name [ ${Function_Name} ]"

  Empty_Var_Control "${HASHICORP_NAMESPACE}" "HASHICORP_NAMESPACE" "2"
  Empty_Var_Control "${CLUSTER_KEYS_FILE}"   "CLUSTER_KEYS_FILE"   "2"
  Empty_Var_Control "${WEBAPP_FILE}"         "WEBAPP_FILE"         "2"

  Do_Vault_Init_If_Needed "${HASHICORP_NAMESPACE}" "${CLUSTER_KEYS_FILE}"
  Get_Vault_Token_From_File "${CLUSTER_KEYS_FILE}"

  Do_Vault_Unseal_If_Needed "${HASHICORP_NAMESPACE}" "vault-0" "${VAULT_UNSEAL_KEY}"

  Do_Vault_Raft_Join_If_Needed "${HASHICORP_NAMESPACE}" "${VAULT_ROOT_TOKEN}" "vault-1"
  Do_Vault_Raft_Join_If_Needed "${HASHICORP_NAMESPACE}" "${VAULT_ROOT_TOKEN}" "vault-2"

  Do_Vault_Unseal_If_Needed "${HASHICORP_NAMESPACE}" "vault-1" "${VAULT_UNSEAL_KEY}"
  Do_Vault_Unseal_If_Needed "${HASHICORP_NAMESPACE}" "vault-2" "${VAULT_UNSEAL_KEY}"

  Do_Vault_Enable_Kv_If_Needed "${HASHICORP_NAMESPACE}" "${VAULT_ROOT_TOKEN}"
  Do_Vault_Create_Webapp_Secret_If_Needed "${HASHICORP_NAMESPACE}" "${VAULT_ROOT_TOKEN}"

  Do_Vault_Enable_Kubernetes_Auth_If_Needed "${HASHICORP_NAMESPACE}" "${VAULT_ROOT_TOKEN}"
  Do_Vault_Configure_Kubernetes_Auth "${HASHICORP_NAMESPACE}" "${VAULT_ROOT_TOKEN}"
  Do_Vault_Write_Webapp_Policy "${HASHICORP_NAMESPACE}" "${VAULT_ROOT_TOKEN}"
  Do_Vault_Write_Webapp_Role "${HASHICORP_NAMESPACE}" "${VAULT_ROOT_TOKEN}"

  Do_Deploy_Webapp "${HASHICORP_NAMESPACE}" "${WEBAPP_FILE}"

  set_message "check" "0" "Liste des pods dans ${HASHICORP_NAMESPACE}"
  kubectl get pods -n "${HASHICORP_NAMESPACE}" || true
  error_CTRL "${?}" "Operation completed"

  ############### Stack_TRACE_BUILDER ################
  Function_PATH="$( dirname "${Function_PATH}" )"
  ####################################################
}

Do_Vault_Full_Setup

#─────────────────────────────────────────────────────────────────────────────
# Accès de test pour les développeurs
#─────────────────────────────────────────────────────────────────────────────
printf "%b\n"
echo "==> Accès utiles:"
echo "Port-forward webapp : kubectl -n ${HASHICORP_NAMESPACE} port-forward $(kubectl -n ${HASHICORP_NAMESPACE} get pod -l app=webapp -o jsonpath="{.items[0].metadata.name}") 8080:8080"
echo "Test HTTP webapp   : curl http://localhost:8080"
printf "%b\n"
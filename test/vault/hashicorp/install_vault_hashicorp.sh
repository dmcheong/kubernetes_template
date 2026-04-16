#!/usr/bin/env bash
#===============================================================================
# Fichier      : install_vault_hashicorp.sh
# Description  : Installe HashiCorp Vault via Helm.
#                Déploie Vault dans Kubernetes avec un fichier de valeurs Helm.
# Prérequis    : helm, kubectl installés — namespace cible disponible ou créable
# Source       : https://developer.hashicorp.com/vault/tutorials/kubernetes-introduction/kubernetes-minikube-raft#kubernetes-minikube-raft
# Note         : ce script n'est pas dans scripts/bin/ par choix pédagogique
#===============================================================================
HASH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HASH_VALUES_FILES="${HASH_DIR}/helm-vault-raft-values.yml"

global_configuration_file="${root_path}/config/global.env"
if [[ -f "${global_configuration_file}" ]]
  then
    . "${global_configuration_file}"
fi

set_message "info" "0" "Exécution du script d installation de Vault dans le namespace ${HASHICORP_NAMESPACE}."

#─────────────────────────────────────────────────────────────────────────────
# Namespace hashicorp / vault (idempotent)
#─────────────────────────────────────────────────────────────────────────────
set_message "info" "0" "Namespace cible: ${HASHICORP_NAMESPACE}"
if ! kubectl get namespace ${HASHICORP_NAMESPACE} >/dev/null 2>&1
  then
    set_message "info" "0" "Création du namespace: ${HASHICORP_NAMESPACE}"
    kubectl create namespace ${HASHICORP_NAMESPACE} >/dev/null
  else
    set_message "EdWMessage" "0" "Le namespace [${HASHICORP_NAMESPACE}] est déjà présent."
fi

#─────────────────────────────────────────────────────────────────────────────
# Ajout du repo Helm HashiCorp (idempotent)
#─────────────────────────────────────────────────────────────────────────────
if ! helm repo list 2>/dev/null | awk 'NR>1 {print $1}' | grep -qx "${HASH_REPO_NAME}"
  then
    set_message "info" "0" "Ajout du repository Helm: ${HASH_REPO_NAME}"
    helm repo add ${HASH_REPO_NAME} ${HASH_REPO_URL} >/dev/null
  else
    set_message "EdWMessage" "0" "Le repository Helm [${HASH_REPO_NAME}] est déjà présent."
fi

# set_message "info" "0" "Mise à jour des repositories Helm."
helm repo update >/dev/null

#─────────────────────────────────────────────────────────────────────────────
# Vérification de disponibilité du chart Vault
#─────────────────────────────────────────────────────────────────────────────
set_message "check" "0" "Vérification de la disponibilité du chart [${HASH_CHART}]"
helm search repo ${HASH_CHART} || true

#─────────────────────────────────────────────────────────────────────────────
# Installation / upgrade Vault (idempotent via helm upgrade --install)
# Le fichier helm-vault-raft-values.yml configure :
#   - le déploiement de Vault
#   - le backend Raft intégré
#   - les paramètres Helm spécifiques à l'environnement
#─────────────────────────────────────────────────────────────────────────────
if helm status ${HASH_RELEASE} -n ${HASHICORP_NAMESPACE} >/dev/null 2>&1
  then
    set_message "EdWMessage" "0" "Release [${HASH_RELEASE}] déjà installée -> upgrade"
  else
    set_message "EdWMessage" "0" "Release [${HASH_RELEASE}] absente -> installation"
fi

set_message "info" "0" "Déploiement de Vault avec le fichier: ${HASH_VALUES_FILES}"
helm upgrade --install "${HASH_RELEASE}" ${HASH_CHART} -n "${HASHICORP_NAMESPACE}" -f "${HASH_VALUES_FILES}" --wait

#─────────────────────────────────────────────────────────────────────────────
# Vérification post-installation
#─────────────────────────────────────────────────────────────────────────────
printf "%b\n"
set_message "check" "0" "Liste des pods de l environnement namespace ${HASHICORP_NAMESPACE}"
kubectl get pods -n ${HASHICORP_NAMESPACE} || true

set_message "info" "0" "Voici la commande pour entrer dans le pod/vault et pouvoir le configurer:"
printf "kubectl exec --stdin=true --tty=true vault-0 -n ${HASHICORP_NAMESPACE} -- /bin/sh"
printf "%b\n"
printf "%b\n"
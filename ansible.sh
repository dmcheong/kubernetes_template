#!/usr/bin/env bash

# set -euo pipefail

# Script d'exécution global d'Ansible, à ne faire qu'en mode Lab.
# Ensuite exécuter le script ./terraform.sh

#########################################
# VARIABLES
#########################################

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BIN_DIR="${ROOT_DIR}/scripts/bin"
ANSIBLE_SCRIPT_DIR="${ROOT_DIR}/scripts/ansible"

ANSIBLE_DIR="${ROOT_DIR}/ansible"

INSTALL_SCRIPT="${BIN_DIR}/install_ansible.sh"
CHECK_SCRIPT="${ANSIBLE_SCRIPT_DIR}/check_ansible_ready.sh"
RUN_SCRIPT="${ANSIBLE_SCRIPT_DIR}/run_playbook.sh"

REQUIREMENTS="${ANSIBLE_DIR}/requirements.yml"

#########################################
# LOGGING
#########################################

log() {
    local level="$1"
    shift

    case "$level" in
        INFO)
            echo "[INFO] $*"
            ;;
        SUCCESS)
            echo "[SUCCESS] $*"
            ;;
        ERROR)
            echo "[ERROR] $*"
            ;;
    esac
}

#########################################
# VALIDATIONS
#########################################

check_project_structure() {

    local required=(
        "${INSTALL_SCRIPT}"
        "${CHECK_SCRIPT}"
        "${RUN_SCRIPT}"
        "${ANSIBLE_DIR}"
    )

    for file in "${required[@]}"; do
        if [[ ! -e "$file" ]]; then
            log ERROR "Fichier manquant : $file"
            exit 1
        fi
    done
}

#########################################
# INSTALLATION
#########################################

install_ansible_if_needed() {

    log INFO "Vérification Ansible"

    bash "${INSTALL_SCRIPT}"
}

#########################################
# PREPARATION
#########################################

prepare_ansible() {

    log INFO "Validation environnement Ansible"

    bash "${CHECK_SCRIPT}"

    if [[ -f "${REQUIREMENTS}" ]]; then

        log INFO "Installation collections Ansible"

        ansible-galaxy collection install \
            -r "${REQUIREMENTS}"

    else

        log INFO "Aucun requirements.yml détecté"

    fi
}

#########################################
# EXECUTION
#########################################

run_playbooks() {

    log INFO "Démarrage configuration environnement"

    bash "${RUN_SCRIPT}"

}

#########################################
# MAIN
#########################################

main() {

    log INFO "Initialisation Ansible"

    check_project_structure

    install_ansible_if_needed

    prepare_ansible

    run_playbooks

    log SUCCESS "Configuration terminée"

}

main "$@"